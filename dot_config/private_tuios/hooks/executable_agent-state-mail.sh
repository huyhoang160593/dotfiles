#!/bin/sh
# tuios [hooks] after-agent-state → mail the person a real text line when a
# pane lands on an alert state (needs_input / errored / done — the states
# [notifications.agent] alerts on).
#
# Why this exists: Ante reports turn status via OSC 7501 with no message text,
# so its agents-view row reads "needs you" with no detail. This hook adds the
# context the row lacks, as mail to `human` (mail overlay, prefix M).
#
# Daemon-run hook: takes effect only after `tuios restart-server`.

state=${TUIOS_AGENT_STATE:-}
[ -n "$state" ] || exit 0
case $state in needs_input | errored | done) ;; *) exit 0 ;; esac

# Settle check: fast approval flaps (needs_input → working within seconds)
# would mail on every blip. Skip if the state did not hold for 2s.
sleep 2
cur=$(tuios get-agent-state -w "$TUIOS_WINDOW_ID" -s "$TUIOS_SESSION_ID" --json 2>/dev/null | jq -r .state 2>/dev/null)
[ "$cur" = "$state" ] || exit 0

msg=${TUIOS_AGENT_MESSAGE:-}
subject="[$TUIOS_SESSION_ID/$TUIOS_WINDOW_NAME] $state"
body="$state${msg:+ — $msg}"

# Ante carries no message in its OSC 7501 report, and tuios has no screen rule
# to read its prompt (peek-prompt refuses). Capture the pane screen instead and
# keep the last non-empty lines, where the dialog sits.
if [ -z "$msg" ] && [ "$state" = needs_input ]; then
  prompt=$(tuios capture-pane -w "$TUIOS_WINDOW_ID" -s "$TUIOS_SESSION_ID" --lines 40 2>/dev/null | sed '/^[[:space:]]*$/d' | tail -12)
  [ -n "$prompt" ] && body="$body

$prompt"
fi

# Never fail the daemon: a mail miss must not break state reporting.
tuios send-agent-message -s "$TUIOS_SESSION_ID" -w human \
  --from "$TUIOS_WINDOW_ID" --subject "$subject" "$body" >/dev/null 2>&1 || true
exit 0
