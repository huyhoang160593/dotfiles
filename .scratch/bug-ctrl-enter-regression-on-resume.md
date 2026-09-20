# [Bug] Regression: Ctrl+Enter broken in fullscreen after `/resume` (related to #193)

## Description

`Ctrl+Enter` fails to insert a newline in the composer when a session is loaded via `/resume` while `render_mode` is `fullscreen`, **inside a terminal multiplexer** (zellij). This is a regression of [#193](https://github.com/AntigmaLabs/ante/issues/193), which fixed `Shift+Enter`/`Ctrl+Enter` not inserting newlines in fullscreen mode. The fix works correctly in a fresh fullscreen session, but breaks again after resuming a previous session. **This issue only occurs inside zellij; it does not reproduce in a plain terminal.**

### Steps to Reproduce

1. Open a session inside **zellij** (terminal multiplexer).
2. Set `"render_mode": "fullscreen"` in `~/.ante/settings.json`.
3. Start a new Ante session and have a short conversation.
4. Exit the session.
5. Restart Ante and use `/resume` to load the previous session.
6. Focus the input composer and type some text.
7. Press `Ctrl+Enter` (or `Shift+Enter`) to insert a newline.

> **Note:** This does not reproduce in a plain terminal (e.g. Ghostty directly). Only observed inside zellij.

### Expected Behavior

`Ctrl+Enter` / `Shift+Enter` inserts a newline in the composer, same as in a fresh fullscreen session.

### Actual Behavior

`Ctrl+Enter` / `Shift+Enter` submits the prompt as if plain `Enter` had been pressed. The partially written message is sent to the model and the composer is cleared.

### Workaround

Switch to `inline` render mode via the TUI (e.g. `/config` or the render mode toggle), then resume the session. `Ctrl+Enter` / `Shift+Enter` will work correctly in inline mode.

### Environment

- Ante version: 0.2.1
- OS: Linux 7.2.6-1-cachyos (CachyOS)
- Terminal: Ghostty (`TERM=xterm-ghostty`)
- Multiplexer: zellij 0.45.1
- Config: `"render_mode": "fullscreen"`

### Additional Notes

It appears that the `/resume` flow may re-initialize the composer without preserving the fullscreen key bindings that were fixed in [#193](https://github.com/AntigmaLabs/ante/issues/193). The modifier key handling may need to be re-applied after session restore, not just at initial startup.

This only reproduces inside a terminal multiplexer (zellij). In a plain terminal, `/resume` in fullscreen mode works correctly. Possible cause: zellij intercepts or rewrites certain modifier key sequences (e.g. `Ctrl+Enter` → `BracketedPaste` or different escape codes), and the resumed session's key handler may not account for the multiplexer's key encoding.
