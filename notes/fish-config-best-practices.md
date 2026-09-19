# Fish shell configuration: best practices for portability and readability

> Research note. Primary sources: official fish docs, the fish source tree, and the
> official chezmoi docs (this repo is a chezmoi dotfiles repo).
> Last verified against fish 4.1 (the fish version installed on this machine — see
> `fish --version`). Early verification of the target machine's fish version used as context for this note:

```
$ fish --version
fish, version 3.7.1
```

---

## 1. Configuration file types and loading order

Fish reads its configuration files in a specific order (from fish language docs [Configuration files](language.html#configuration)):

### 1.1 Primary config files

1. **`$__fish_config_dir/conf.d/*.fish`** — i.e. `~/.config/fish/conf.d/*.fish`
   - Sourced in **lexicographic order** (by filename)
   - Every `.fish` file in this directory is sourced, regardless of whether `config.fish` exists
   - This is where **most configuration** belongs

2. **`$__fish_config_dir/config.fish`** — i.e. `~/.config/fish/config.fish`
   - Sourced **after** all of `conf.d/`
   - Runs only once per fish session on startup
   - This is where **critical shell-wide settings** should go

### 1.2 Function files

3. **`$__fish_config_dir/functions/*.fish`** — i.e. `~/.config/fish/functions/*.fish`
   - Files in this directory are **autoloaded lazily** on first use of the function
   - **Not** sourced at startup like `conf.d/` and `config.fish`
   - This is a common point of confusion

### 1.3 Universal variables

- **`~/.config/fish/fish_variables`** — Contains **universal variables**
  - Also reads aliases and abbreviations from this file
  - Should NOT be edited directly; use fish scripts or interactive commands
  - Do NOT append to universal variables in `config.fish` because they grow with each shell instance

### 1.4 Environment variable

- **`$XDG_CONFIG_HOME`** — Defaults to `~/.config/` if not set

## 2. Recommended structure/organization conventions

### 2.1 Separate configuration domains

Best practice is to organize configuration into logical groups:

#### 2.1.1 Aliases and abbreviations

- **Aliases**: Use `abbr` command for replacements that you want to be visible in command history
- **Abbreviations**: Use `abbr --regex` for powerful pattern matching expansions
- Keep machine-specific aliases separate from shared configurations

#### 2.1.2 Functions

- Define complex commands as functions in `~/.config/fish/functions/*.fish`
- Use `abbr --function` for abbreviations that call functions
- Functions are automatically available to all running shells

#### 2.1.3 Environment variables

- **Global variables**: Use `set -g` for session-wide settings
- **Universal variables**: Use `set -U` for persistence across sessions (stored in `fish_variables`)
- **Function variables**: Use `set -f` for function-specific settings

#### 2.1.4 Key bindings

- Define custom key bindings in `~/.config/fish/conf.d/` or `~/.config/fish/functions/*.fish`
- Use `bind` command to modify bindings
- Consider separate files for different binding modes (emacs/vi)

#### 2.1.5 Prompt configuration

- Define `fish_prompt`, `fish_right_prompt`, and `fish_mode_prompt` functions
- Store prompts in autoload directory (`~/.config/fish/functions/`) for consistency
- Use `funced` and `funcsave` for easy editing

#### 2.1.6 Completions

- Place command-specific completions in `~/.config/fish/completions/`
- These are loaded on demand, not at startup

### 2.2 Conditional blocks

#### 2.2.1 Interactive vs. non-interactive

```fish
if status --is-interactive
    # Commands to run in interactive sessions can go here
end
```

#### 2.2.2 Login vs. non-login

```fish
if status --is-login
    # Commands to run in login shells (e.g., setting PATH)
end
```

#### 2.2.3 Combined conditions

```fish
if status --is-login
    # Setup login-specific settings
    set -gx PATH $PATH /some/path
end

if status --is-interactive
    # Setup interactive-specific settings
    fish_add_path -g ~/.local/bin
end
```

## 3. Reusable-across-machines practices

### 3.1 Machine-specific configuration

#### 3.1.1 Using chezmoi

- Since this is a chezmoi dotfiles repo, use `chezmoi` for cross-machine configuration management
- Place machine-specific config in `chezmoi` data directories or use conditional blocks

#### 3.1.2 Conditional based on hostname

```fish
if test (hostname) = "workstation"
    # Workstation-specific settings
    set -gx EDITOR vim
else
    # Home machine settings
    set -gx EDITOR nano
end
```

#### 3.1.3 Conditional based on OS

```fish
switch (uname)
case Linux
    # Linux-specific settings
    alias ls="ls --color=auto"
case Darwin
    # macOS-specific settings
    alias ls="ls -G"
case '*'
    # Other Unix-like systems
end
```

### 3.2 External tool configuration

#### 3.2.1 Using `fish_add_path`

```fish
# Add to global path (available to all shells)
fish_add_path -g ~/.local/bin

# Add to session path (available to this shell only)
fish_add_path ~/.local/bin
```

#### 3.2.2 External configuration files

```fish
# Source external scripts only if they exist
if test -f ~/.config/fish/external_config.fish
    source ~/.config/fish/external_config.fish
end
```

## 4. Common gotchas and best practices for aliases vs functions vs abbr

### 4.1 Aliases vs Functions

#### 4.1.1 Aliases

```fish
# Simple alias (creates a function)
abbr -a gco git checkout
# When you type 'gco', it becomes 'git checkout' in command line
# The actual command is stored in history
```

**Best for:**
- Simple command replacements
- Want the actual command visible in history
- Want to be able to modify the command before execution

#### 4.1.2 Functions

```fish
function ll
    ls -l $argv
end
# Define complex commands with arguments
```

**Best for:**
- Complex commands with multiple steps
- Commands that need arguments passed through
- Want to define custom behavior

#### 4.1.3 Abbreviations

```fish
# Regex-based abbreviation
abbr --add dotdot --regex '^\.\.+$' --function multicd

# Function-based abbreviation
abbr --add gco git checkout
```

**Best for:**
- Pattern matching expansions
- Command substitutions
- More powerful than aliases

### 4.2 Key differences

#### 4.2.1 Visibility

- **Aliases/abbreviations**: Visible in command line, can be edited before execution
- **Functions**: Not visible until after function definition, cannot be easily edited mid-command

#### 4.2.2 History

- **Aliases/abbreviations**: Store the actual command in history
- **Functions**: Store the function name in history

#### 4.2.3 Complexity

- **Aliases/abbreviations**: Simple string/function replacements
- **Functions**: Full scripting language capabilities

### 4.3 Gotchas

#### 4.3.1 Recursive alias calls

```fish
# Bad - This will call itself forever
function ls
    ls $argv
end

# Good - Use 'command' to bypass the alias
function ls
    command ls $argv
end
```

#### 4.3.2 Variable expansion in abbreviations

```fish
# Bad - Variable won't be expanded
abbr -a path "echo \$HOME"

# Good - Use command substitution
abbr -a path "echo (echo $HOME)"
```

#### 4.3.3 Function autoloading

```fish
# Functions in ~/.config/fish/functions/ are loaded automatically
# They are available immediately after being defined or after sourcing
```

## 5. Readability and maintainability best practices

### 5.1 Code organization

#### 5.1.1 File naming

```fish
# Good organization:
~/.config/fish/conf.d/00_initialization.fish     # Path setup, basic settings
~/.config/fish/conf.d/01_aliases.fish              # All aliases and abbreviations
~/.config/fish/conf.d/02_functions.fish             # Function definitions
~/.config/fish/conf.d/03_key_bindings.fish          # Key configuration
~/.config/fish/conf.d/04_prompt.fish               # Prompt configuration
~/.config/fish/conf.d/05_completions.fish           # External tool completions
~/.config/fish/conf.d/06_custom_commands.fish       # Custom scripts

~/.config/fish/functions/*.fish                    # Autoloaded functions
~/.config/fish/completions/*.fish                  # External completions
```

#### 5.1.2 Comments

```fish
# Use clear, descriptive comments
# Fish comments start with #

# Setup PATH - add user bin to global path
fish_add_path -g ~/.local/bin

# Start starship prompt - handles colors, git info, etc.
starship init fish | source
```

#### 5.1.3 Error handling

```fish
# Source external scripts safely
if test -f /path/to/script.fish
    source /path/to/script.fish
    or begin
        echo "Warning: Failed to source /path/to/script.fish" >&2
    end
end
```

### 5.2 Function organization

#### 5.2.1 Function categories

```fish
# Utility functions
function is_executable
    test -x (command -v $argv[1])
end

# Path helpers
function add_to_path
    if not contains $argv[1] $$argv[2]
        set -gx PATH $argv[1] $$PATH
    end
end

# Prompt components
function prompt_segment
    set -l color $argv[1]
    set -l text $argv[2]
    if set_color $color
        echo -n " ".$text
    end
end
```

#### 5.2.2 Function documentation

```fish
function my_function --description "Do something useful"
    # This function does X, Y, and Z
    # Arguments:
    #   $argv[1] - First argument
    #   $argv[2] - Second argument
    #
    # Examples:
    #   my_function arg1 arg2
    #
    # Notes:
    #   This function requires ...
    
    # Function body here...
end
```

### 5.3 Variable management

#### 5.3.1 Variable naming

```fish
# Good variable names
set -gx EDITOR vim                    # Environment variable
set -gx PATH $PATH /some/path        # PATH variable (note: $PATH is a list)
set -gx USER_CONFIG_DIR ~/.config     # Descriptive name
set -gx FOO_BAR_BAZ 123               # UPPER_CASE for environment variables

# Bad variable names
set -gx myVar 123                     # camelCase not recommended
unset -n someVariable                # Unclear what this variable was for
```

#### 5.3.2 Variable scopes

```fish
# Global - available to all commands in this session
set -g fish_greeting "Hello"

# Universal - available to all fish sessions on this computer
set -U fish_greeting "Hello"

# Function - available only in this function
set -f temp_var "value"
```

### 5.4 Debugging and testing

#### 5.4.1 Debug mode

```fish
# Add debug output to functions
function my_function
    if set -q fish_debugging
        echo "DEBUG: my_function called with: $argv" >&2
    end
    # ... rest of function
end
```

#### 5.4.2 Version checking

```fish
# Check fish version before running version-specific code
if test (fish --version | string split " " | string match -r "[0-9]+\.[0-9]+" | string replace " " "") ">=" 3.1
    # Use newer features
    set -gx SOME_FEATURE 1
else
    # Use fallback
    set -gx SOME_FEATURE 0
end
```

## 6. References

- [Official fish documentation: Configuration files](https://fishshell.com/docs/current/language.html#configuration-files)
- [Official fish documentation: Functions](https://fishshell.com/docs/current/language.html#functions)
- [Official fish documentation: Function autoloading](https://fishshell.com/docs/current/language.html#syntax-function-autoloading)
- [Official fish documentation: Interactive use](https://fishshell.com/docs/current/interactive.html)
- [Official fish documentation: Abbreviations](https://fishshell.com/docs/current/interactive.html#abbreviations)
- [Official fish documentation: Variable scope](https://fishshell.com/docs/current/language.html#variables-scope)
- [Official fish documentation: Universal variables](https://fishshell.com/docs/current/language.html#variables-universal)
- [Official fish documentation: PATH variables](https://fishshell.com/docs/current/language.html#path-variables)
- [Official fish documentation: Writing your own completions](https://fishshell.com/docs/current/completions.html)
- [Official fish documentation: Writing your own prompt](https://fishshell.com/docs/current/prompt.html)
- [chezmoi: Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [fish-shell source repository](https://github.com/fish-shell/fish-shell)

## 7. Example complete configuration structure

```
~/.config/fish/
├── conf.d/
│   ├── 00_initialization.fish          # Basic setup, PATH, essential functions
│   ├── 01_aliases.fish                 # All user-defined abbreviations and aliases
│   ├── 02_functions.fish                # Complex function definitions
│   ├── 03_key_bindings.fish             # Custom key bindings
│   ├── 04_prompt.fish                   # Prompt configuration
│   └── 05_completions.fish              # External tool completions
├── functions/                           # Autoloaded functions
│   ├── fish_prompt.fish                # User-defined prompt
│   ├── custom_functions.fish           # Other functions
│   └── helpers.fish                    # Utility functions
├── completions/                         # External completions
│   ├── git.fish                        # Git completions
│   └── npm.fish                        # Npm completions
├── config.fish                          # Global configuration
├── fish_variables                       # Universal variables
└── README.md                            # Documentation
```

This structure provides:
- **Logical separation** of concerns
- **Easy maintenance** with focused files
- **Machine-specific config** can be added to `conf.d/` with conditional blocks
- **Version control friendly** with small, focused changes
- **Backup safe** - changes to `fish_variables` can be made elsewhere

---

*Document created as part of fish configuration best practices research.*
