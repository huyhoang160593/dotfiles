# lazygit + Ante Integration for AI-Generated Commit Messages

## Summary

lazygit has **no built-in AI commit message feature**, but its custom command system makes integration with Ante straightforward. Ante's headless mode (`-p` flag, stdin support) maps directly onto lazygit's custom command infrastructure.

## lazygit Config Options Relevant to AI Integration

### `os.edit` / `os.editInTerminal`

- `os.edit`: Command template for editing a file. Contains `{{filename}}`.
- `os.editInTerminal`: Whether lazygit suspends until the edit process returns.
- **Relevance**: These control the external editor for commit messages (`C` or `e` in commit message view), but they operate on a *file*, not on diff output. Not directly useful for AI generation.

**Source**: [lazygit Config.md — os section](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)

### `git.commit` config

```yaml
git:
  commit:
    signOff: false
    autoWrapCommitMessage: true
    autoWrapWidth: 72
```

No built-in `prompt`, `ai`, or `generateMessage` option exists. The commit config is limited to sign-off and wrapping behavior.

**Source**: [lazygit config schema — CommitConfig](https://raw.githubusercontent.com/jesseduffield/lazygit/master/schema/config.json)

### `customCommands` (primary integration point)

lazygit's custom command system supports arbitrary shell commands with:
- Context-aware keybindings (e.g., `files` context to run when staged files are visible)
- `output: terminal` to suspend lazygit and run interactively
- `output: popup` to display output in a popup
- `subprocess: true` to run in a subprocess
- `loadingText` for progress indication
- Go template placeholders for accessing git state (staged files, diffs, etc.)
- `prompts` for user input before command execution

**Source**: [Custom_Command_Keybindings.md](https://github.com/jesseduffield/lazygit/blob/master/docs/Custom_Command_Keybindings.md)

## Ante Headless Mode

Ante supports non-interactive/headless execution via:

```
ante -p "prompt text"         # Run a prompt in headless mode
echo "diff output" | ante -p "Generate a commit message for this diff"  # Pipe stdin
```

Key flags:
- `-p, --prompt <PROMPT>` — prompt to run in headless mode (also supports stdin when piped)
- `--permission-mode yolo` — auto-approve all tool calls (headless default)
- `--output-format minimal|human|json` — control output format
- `--no-skills` — skip skill loading for faster execution
- `--tools Bash,Read` — limit tools available
- `--no-session-save` — skip session persistence

**Source**: `ante --help` output, 2026-09-20

## Integration Patterns

### Pattern 1: Generate Commit Message via Custom Command (Recommended)

A custom command that pipes `git diff --cached` to Ante headless mode, then opens the commit editor with the generated message.

```yaml
customCommands:
  - key: '<c-a>'
    context: 'files'
    description: 'Generate commit message with AI'
    loadingText: 'Generating commit message...'
    command: |
      #!/bin/bash
      MSG=$(git diff --cached | ante --no-skills --no-session-save -p "Generate a concise conventional commit message for these staged changes. Output ONLY the commit message, nothing else." 2>/dev/null | tail -1)
      echo "$MSG" > /tmp/lazygit_commit_msg.txt
      git commit -F /tmp/lazygit_commit_msg.txt
    subprocess: true
```

**Note**: lazygit's custom command templating does not support piping or shell redirections natively — the `command` field runs via Go's `os/exec`. Using a bash script (via `#!/bin/bash` shebang) or wrapping in `bash -c "..."` is needed for pipes and variable capture.

**Source**: [Custom Commands Compendium](https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium)

### Pattern 2: Generate + Open for Editing

Generate the message with Ante, then open it in lazygit's commit editor for review:

```yaml
customCommands:
  - key: '<c-a>'
    context: 'files'
    description: 'AI commit message (edit before commit)'
    loadingText: 'Generating commit message...'
    command: |
      #!/bin/bash
      git diff --cached | ante --no-skills --no-session-save -p "Generate a concise conventional commit message for these staged changes. Output ONLY the commit message, nothing else." 2>/dev/null | tail -1 > /tmp/lazygit_commit_msg.txt
    subprocess: true
    after:
      checkForConflicts: false
```

Then use `C` (the built-in commit key) which opens the editor. Since lazygit writes the initial message from `GIT_EDITOR` or its internal editor, you'd need to pre-populate the file. However, lazygit doesn't natively read a file for the commit message — it uses its own internal editor.

**Better approach for edit-before-commit**: Use `output: terminal` and `subprocess: true`:

```yaml
customCommands:
  - key: '<c-a>'
    context: 'files'
    description: 'AI commit message (edit before commit)'
    loadingText: 'Generating commit message...'
    command: |
      #!/bin/bash
      MSG=$(git diff --cached | ante --no-skills --no-session-save -p "Generate a concise conventional commit message for these staged changes. Output ONLY the commit message, nothing else." 2>/dev/null | tail -1)
      git commit -m "$MSG"
    output: terminal
    subprocess: true
```

### Pattern 3: Copy to Clipboard (Lumen-style)

Similar to the [Lumen/discussion #4100 pattern](https://github.com/jesseduffield/lazygit/discussions/4100) but using Ante:

```yaml
customCommands:
  - key: '<c-a>'
    context: 'files'
    description: 'AI commit message to clipboard'
    loadingText: 'Generating commit message...'
    command: |
      #!/bin/bash
      MSG=$(git diff --cached | ante --no-skills --no-session-save -p "Generate a concise conventional commit message for these staged changes. Output ONLY the commit message, nothing else." 2>/dev/null | tail -1)
      echo -n "$MSG" | wl-copy  # or pbcopy on macOS, xclip on X11
    output: popup
    outputTitle: "AI Commit Message (Copied to Clipboard)"
```

**Source**: [Discussion #4100](https://github.com/jesseduffield/lazygit/discussions/4100) — shell-ask pattern

### Pattern 4: Using `os.edit` with Ante as Editor

You can set Ante as the editor for commit messages, though this is less targeted:

```yaml
os:
  edit: "ante -p 'Review and improve this file content: {{filename}}'"
  editInTerminal: true
```

This would launch Ante when you press `e` to edit a file, but it doesn't specifically handle commit message generation from diffs.

**Source**: [Config.md — os section](https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md)

## Limitations and Considerations

1. **No built-in "generate commit message" feature in lazygit**: There is an open Ideas discussion ([#4666](https://github.com/jesseduffield/lazygit/discussions/4666)) requesting AI commit message suggestions, but it's not implemented natively.

2. **Template limitations**: lazygit's `command` field uses Go templates, which don't support shell pipes natively. Commands with pipes, variable capture, or complex shell logic need a script or `bash -c "..."` wrapper.

3. **Commit message injection**: lazygit doesn't support pre-populating the commit message editor from a file or command output. The generated message must either be used directly via `git commit -m "..."` or copied to clipboard for manual paste.

4. **Performance**: Ante's headless mode will load skills by default. Use `--no-skills --no-session-save` for faster execution when only generating a commit message.

5. **`git diff --cached` vs full diff**: The custom command runs in lazygit's context, so `git diff --cached` captures staged changes. Unstaged changes would need `git diff`.

## Existing Community Patterns

- [Discussion #4100](https://github.com/jesseduffield/lazygit/discussions/4100): `shell-ask` integration (pure bash AI tool) — uses custom command to pipe diff to AI and copy result to clipboard.
- [Discussion #4666](https://github.com/jesseduffield/lazygit/discussions/4666): Lumen integration — custom command pipes staged files to Lumen, copies to clipboard, user pastes into commit editor.
- [Discussion #5963](https://github.com/jesseduffield/lazygit/discussions/5963): "UI Implemented an AI Generate Commit Message" — appears to be a custom implementation (closed).
- [Custom Commands Compendium](https://github.com/jesseduffield/lazygit/wiki/Custom-Commands-Compendium): Community wiki with examples including conventional commit patterns.
