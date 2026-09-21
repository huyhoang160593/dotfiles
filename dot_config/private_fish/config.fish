# ── PATH ──────────────────────────────────────────────────────
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.ante/bin

# ── Environment ───────────────────────────────────────────────
set -gx BROWSER helium

# ── SSH agent ─────────────────────────────────────────────────
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) >/dev/null
end

# ── Interactive only ──────────────────────────────────────────
if status is-interactive
    # Disable default fish greeting
    set fish_greeting ""

    # Abbreviations (eza)
    abbr -a ls  eza --icons=auto
    abbr -a ll  eza -lhF --git --group-directories-first --icons=auto
    abbr -a la  eza -lahHig --time-style=long-iso --git --color-scale --icons=auto
    abbr -a lx  eza -lahHig@ --time-style=long-iso --git --color-scale --icons=auto
    abbr -a lS  eza -1 --icons=auto
    abbr -a lt  eza -TL=2 --icons=auto

    # Tool initializers
    if type -q starship
        starship init fish | source
    end

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source
    end

    # System info
    if type -q fastfetch
        fastfetch -c /usr/share/fastfetch/presets/examples/12.jsonc
    end
end


