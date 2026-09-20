if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Setup PATH
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.ante/bin

# Default browser for xdg-open
set -gx BROWSER helium

# Setup abbr with eza to replace ls
abbr -a ls eza --icons=auto
abbr -a ll eza -lhF --git --icons=auto
abbr -a llm eza -lhdG --git -s=modified --icons=auto
abbr -a la eza -lAhHigUmu --time-style=long-iso --git --color-scale --icons=auto
abbr -a lx eza -lAhHigUmu@ --time-style=long-iso --git --color-scale --icons=auto
abbr -a lS eza -1 --icons=auto
abbr -a lt eza -TL=2 --icons=auto

# Start starship
starship init fish | source

# Set up zoxide
zoxide init fish | source

# Set up fzf key bindings
fzf --fish | source

# Set up ssh-agent
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
end


