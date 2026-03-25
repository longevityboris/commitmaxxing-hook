#!/usr/bin/env bash
# commitmaxxing.sh - Auto-commit after every Claude turn
# Fires on Stop hook = one commit per logical unit of Claude work

set -euo pipefail

# Only run in git repos
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Only commit if there are actual changes (staged or unstaged)
if git diff --quiet HEAD 2>/dev/null && git diff --cached --quiet 2>/dev/null && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    exit 0
fi

# Stage everything
git add -A

# Double-check something is actually staged
git diff-index --quiet HEAD 2>/dev/null && exit 0

# Build a commit message from what changed
CHANGED_FILES=$(git diff --cached --name-only 2>/dev/null | head -5)
FILE_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
FIRST_FILE=$(echo "$CHANGED_FILES" | head -1 | xargs basename 2>/dev/null || echo "files")

if [ "$FILE_COUNT" -eq 1 ]; then
    MSG="update $FIRST_FILE"
elif [ "$FILE_COUNT" -le 5 ]; then
    MSG="update $FILE_COUNT files including $FIRST_FILE"
else
    MSG="update $FILE_COUNT files"
fi

git commit -m "$MSG" 2>/dev/null || true
