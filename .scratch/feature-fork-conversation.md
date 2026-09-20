# [Feature Request] Fork conversation from any message with tree view

## Problem

In long sessions, the conversation often goes down a rabbit hole — the model explores an approach that doesn't work out, asks clarifying questions, or diverges from the main task. The user is left with a linear transcript full of dead ends mixed with productive work. There's no way to branch off from a specific point without either:

- Losing the main thread by starting a fresh session
- Manually retracing steps and repeating context

## Proposed Solution

Allow the user to **fork a conversation from any message** into a new thread. The forked thread starts from the selected message but diverges independently, so the user can explore side questions, try alternative approaches, or get clarifications — then return to the main thread when ready.

### Core feature: Fork from message

- User selects a message in the conversation (e.g. via the transcript view `Ctrl+O` or a new interaction mode)
- A context menu offers **"Fork here"**
- A new conversation thread is created, inheriting all context up to and including the selected message
- The original thread remains untouched
- The user works in the fork, gets their answer, and switches back to the main thread

### Bonus feature: Conversation tree view

- Display the conversation as a **tree structure** where each fork is a visible branch
- The user can navigate between branches to see what was explored and where each fork originated
- Visual example:

```
├─ message 1
├─ message 2
│  ├─ message 3 (main)
│  │  └─ message 4
│  └─ [fork] message 3' (side question)
│     └─ message 4' (answer found)
│  └─ message 5 (main continues)
│     └─ message 6
```

- Switching between branches should be seamless — the model context switches to the selected branch

## Why this matters

- **Real workflows branch naturally.** When debugging, you often need to ask "what if we try X?" without losing the main investigation. Currently there's no clean way to do this.
- **Context preservation.** A fork carries the full history up to the branch point, so the model has all the context it needs without the user having to re-explain.
- **Exploration without commitment.** Users can try risky or exploratory approaches in a fork without polluting the main thread's context.
- **Competing tools have this.** ChatGPT's conversation branching and Cursor's composer history show that non-linear conversation is a valuable UX pattern.

## Use cases

- **Debugging:** Main thread investigates cause A. Fork to quickly check cause B. If B is the real cause, work there; if not, switch back.
- **Clarification:** Fork to ask the model to explain a concept in more detail, then return to the main task with better understanding.
- **Alternative approaches:** Fork to try a different implementation strategy. Compare results across forks to pick the best one.
- **Multi-task sessions:** One conversation branches into handling multiple related subtasks, each in its own fork.

## Alternatives considered

- `/clear` and start over — Loses all context and progress.
- Just send a correction message — Works for small detours but the dead-end context stays in the transcript and pollutes future turns.
- Separate sessions per approach — Requires manually re-establishing context in each one.

## Environment

- Ante version: 0.2.1
- OS: Linux 7.2.6-1-cachyos (CachyOS)
- Terminal: Ghostty
