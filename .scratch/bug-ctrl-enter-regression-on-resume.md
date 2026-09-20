# [Bug] Regression: Ctrl+Enter broken in fullscreen after `/resume` (related to #193)

## Description

`Ctrl+Enter` fails to insert a newline in the composer when a session is loaded via `/resume` while `render_mode` is `fullscreen`. This is a regression of [#193](https://github.com/AntigmaLabs/ante/issues/193), which fixed `Shift+Enter`/`Ctrl+Enter` not inserting newlines in fullscreen mode. The fix works correctly in a fresh fullscreen session, but breaks again after resuming a previous session.

### Steps to Reproduce

1. Set `"render_mode": "fullscreen"` in `~/.ante/settings.json`.
2. Start a new Ante session and have a short conversation.
3. Exit the session.
4. Restart Ante and use `/resume` to load the previous session.
5. Focus the input composer and type some text.
6. Press `Ctrl+Enter` (or `Shift+Enter`) to insert a newline.

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
- Config: `"render_mode": "fullscreen"`

### Additional Notes

It appears that the `/resume` flow may re-initialize the composer without preserving the fullscreen key bindings that were fixed in [#193](https://github.com/AntigmaLabs/ante/issues/193). The modifier key handling may need to be re-applied after session restore, not just at initial startup.
