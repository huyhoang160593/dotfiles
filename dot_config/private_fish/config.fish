if status is-interactive
    # Commands to run in interactive sessions can go here
end
# Setup PATH
fish_add_path -g ~/.local/bin

# Setup abbr with exa to replace ls
abbr -a ls eza
abbr -a ll eza -lbF --git
abbr -a llm eza -lbGd --git --sort=modified
abbr -a la eza -lbhHigUmuSa --time-style=long-iso --git --color-scale
abbr -a lx eza -lbhHigUmuSa@ --time-style=long-iso --git --color-scale
abbr -a lS eza -1
abbr -a lt eza --tree --level=2

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

