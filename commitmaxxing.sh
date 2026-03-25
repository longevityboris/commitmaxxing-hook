#!/usr/bin/env bash
# commitmaxxing.sh - Auto-commit after every Claude turn
# Fires on Stop hook = one commit per logical unit of Claude work
#
# NEVER use set -e in hooks — a failed command must not block Claude.

# Use CLAUDE_PROJECT_DIR if available, fall back to CWD
DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$DIR" 2>/dev/null || exit 0

# Only run in git repos
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Bail if git is mid-rebase, mid-merge, or mid-cherry-pick
if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ] || \
   [ -f ".git/MERGE_HEAD" ] || [ -f ".git/CHERRY_PICK_HEAD" ]; then
    exit 0
fi

# Bail if HEAD is detached (e.g. during interactive rebase)
git symbolic-ref HEAD &>/dev/null || exit 0

# Only commit if there are actual changes (staged, unstaged, or untracked)
if git diff --quiet HEAD 2>/dev/null && \
   git diff --cached --quiet 2>/dev/null && \
   [ -z "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
    exit 0
fi

# Stage everything (respects .gitignore)
git add -A 2>/dev/null || exit 0

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
