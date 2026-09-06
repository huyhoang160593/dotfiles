if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

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

