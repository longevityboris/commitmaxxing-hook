#!/usr/bin/env bash
# Remind Claude to commit. That's it.
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
echo '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes. Commit now with a descriptive message before continuing."}}'
