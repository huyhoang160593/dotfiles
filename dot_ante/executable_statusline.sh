#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
provider=$(echo "$input" | jq -r '.provider // "local"')
version=$(echo "$input" | jq -r '.version // "?"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' | xargs -I{} basename "{}")
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
pr_number=$(echo "$input" | jq -r '.pr.number // empty')
pr_url=$(echo "$input" | jq -r '.pr.url // empty')
git_branch=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty' | xargs -I{} sh -c 'cd "{}" && git branch --show-current 2>/dev/null')

c_cyan()  { printf '\033[36m%s\033[0m' "$1"; }
c_green() { printf '\033[32m%s\033[0m' "$1"; }
c_yellow(){ printf '\033[33m%s\033[0m' "$1"; }
c_red()   { printf '\033[31m%s\033[0m' "$1"; }
c_bold()  { printf '\033[1m%s\033[0m' "$1"; }
c_muted() { printf '\033[90m%s\033[0m' "$1"; }
c_link()  { printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$1" "$2"; }

# Format token count
fmt_tokens() {
    if [ "$1" -ge 1000000 ] 2>/dev/null; then echo "$1" | awk '{printf "%.1fM", $1/1000000}'
    elif [ "$1" -ge 1000 ] 2>/dev/null; then echo "$1" | awk '{printf "%.1fk", $1/1000}'
    else echo "$1"; fi
}

# ── Line 1: model · provider ⚡ · dir · git · PR · version ──
printf '%s' "$(c_cyan "$(c_bold "$model")")"
printf '%s' " $(c_muted '·') $(c_muted "$provider")"
if [ "$thinking" = "true" ]; then
    printf '%s' " $(c_yellow '⚡')"
fi
printf '%s' " $(c_muted '·') $dir"
if [ -n "$git_branch" ]; then
    printf '%s' " $(c_muted 'on') $(c_green "$git_branch")"
fi
if [ -n "$pr_number" ] && [ "$pr_number" != "null" ]; then
    if [ -n "$pr_url" ] && [ "$pr_url" != "null" ]; then
        printf '%s' " $(c_muted '·') $(c_link "$pr_url" "$(c_muted "PR #${pr_number}")")"
    else
        printf '%s' " $(c_muted '·') $(c_muted "PR #${pr_number}")"
    fi
fi
printf '%s' " $(c_muted "v${version}")"
printf '\n'

# ── Line 2: context bar (only if context_window data exists) ──
if [ -n "$pct" ] && [ "$pct" != "null" ]; then
    pct_int=$(echo "$pct" | cut -d. -f1)

    BAR_WIDTH=20
    if [ "$pct_int" -ge 90 ] 2>/dev/null; then bar_color() { c_red "$1"; }
    elif [ "$pct_int" -ge 70 ] 2>/dev/null; then bar_color() { c_yellow "$1"; }
    else bar_color() { c_green "$1"; }; fi

    FILLED=$((pct_int * BAR_WIDTH / 100))
    EMPTY=$((BAR_WIDTH - FILLED))
    BAR=""
    i=0; while [ "$i" -lt "$FILLED" ]; do BAR="${BAR}━"; i=$((i + 1)); done
    i=0; while [ "$i" -lt "$EMPTY" ]; do BAR="${BAR}─"; i=$((i + 1)); done

    # Tokens display: "36.0k / 200k"
    TOKENS_DISPLAY=""
    if [ -n "$total_tokens" ] && [ "$total_tokens" != "null" ] && [ "$total_tokens" -gt 0 ] 2>/dev/null; then
        TOKENS_DISPLAY=$(fmt_tokens "$total_tokens")
        if [ -n "$window_size" ] && [ "$window_size" != "null" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
            TOKENS_DISPLAY="${TOKENS_DISPLAY} / $(fmt_tokens "$window_size")"
        fi
    fi

    printf '%s' "$(bar_color "$BAR")"
    printf '%s' " ${pct}%"
    if [ -n "$TOKENS_DISPLAY" ]; then
        printf '%s' " $(c_muted "(${TOKENS_DISPLAY})")"
    fi
    printf '\n'
fi
