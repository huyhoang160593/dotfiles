# [Feature Request] Undo/Delete sent messages to prevent context poisoning

## Problem

When a user accidentally sends an incorrect or unintended prompt, there is no way to remove or undo it from the conversation history. The wrong message remains in the context and can "poison" subsequent exchanges — the model may continue reasoning from the incorrect input, leading to degraded responses or misguided actions.

Currently, the only workarounds are:
- `Ctrl+C` to interrupt mid-turn (but the message is still in history)
- Starting a new session with `/clear` (loses all useful context)

Neither preserves the conversation while removing just the offending message.

## Proposed Solution

Add the ability to **undo or delete a specific message** from the conversation after it has been sent. Some options:

1. **Undo last sent message** — A keyboard shortcut (e.g., `Ctrl+Z` or a slash command like `/undo`) that removes the most recent user message and the model's response from context before the next turn.

2. **Edit & resend** — Allow the user to select a previous message, edit it, and resend it. The original message and its response would be replaced in the context.

3. **Message picker** — A UI (similar to transcript view `Ctrl+O`) where the user can select and delete specific messages.

## Why this matters

- **Context poisoning is a real problem.** One wrong message can derail a long session, forcing the user to restart and lose all progress.
- **Other agents support this.** Claude Code allows editing/resending previous messages, which is a significant UX advantage for long sessions.
- **Low-effort fix.** Even a simple `/undo` command that removes the last user+assistant message pair would cover the most common case.

## Alternatives considered

- `/clear` — Too destructive; wipes the entire session.
- Just send a correction message — Works sometimes, but the poisoned context may still influence model behavior.

## Environment

- Ante version: 0.2.1
- OS: Linux 7.2.6-1-cachyos (CachyOS)
- Terminal: Ghostty
