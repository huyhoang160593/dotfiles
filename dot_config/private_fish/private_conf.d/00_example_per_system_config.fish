# ── Per-system config example ──────────────────────────────────
# Copy this file and rename (e.g. 01_work_laptop.fish) to add
# machine-specific settings that should NOT be shared via chezmoi.
#
# Naming convention:
#   NN_description.fish   — NN = two-digit number for ordering
#
# Tips:
#   - Wrap things in `if status is-interactive` if needed
#   - Use `type -q <cmd>` to guard tool-specific init
#   - This directory runs BEFORE config.fish
# ──────────────────────────────────────────────────────────────

# ── PATH additions ────────────────────────────────────────────
# fish_add_path -g /path/to/only/this/machine

# ── Environment ───────────────────────────────────────────────
# set -gx MY_VAR "value"

# ── Tool init (interactive only) ──────────────────────────────
# if status is-interactive
#     if type -q some-tool
#         some-tool init fish | source
#     end
# end
