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

# Bail if git is mid-rebase, mid-merge, mid-cherry-pick, or mid-bisect
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null) || exit 0
if [ -d "$GIT_DIR/rebase-merge" ] || [ -d "$GIT_DIR/rebase-apply" ] || \
   [ -f "$GIT_DIR/MERGE_HEAD" ] || [ -f "$GIT_DIR/CHERRY_PICK_HEAD" ] || \
   [ -f "$GIT_DIR/BISECT_LOG" ]; then
    exit 0
fi

# Bail if HEAD is detached (e.g. during interactive rebase)
git symbolic-ref HEAD &>/dev/null || exit 0

# Single porcelain check for any changes (faster than 3 separate git calls)
STATUS=$(git status --porcelain=v1 --untracked-files=normal --ignore-submodules=dirty 2>/dev/null)
[ -z "$STATUS" ] && exit 0

# Stage everything (respects .gitignore)
git add -A 2>/dev/null || exit 0

# Double-check something is actually staged
git diff-index --quiet HEAD 2>/dev/null && exit 0

# Build a commit message from what changed
FILE_COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
# Use head -1 with basename safely (no xargs, handles spaces)
FIRST_FILE=$(git diff --cached --name-only 2>/dev/null | head -1)
FIRST_FILE="${FIRST_FILE##*/}"  # basename without xargs (handles spaces)
[ -z "$FIRST_FILE" ] && FIRST_FILE="files"

if [ "$FILE_COUNT" -eq 1 ] 2>/dev/null; then
    MSG="update $FIRST_FILE"
elif [ "$FILE_COUNT" -le 5 ] 2>/dev/null; then
    MSG="update $FILE_COUNT files including $FIRST_FILE"
else
    MSG="update $FILE_COUNT files"
fi

git commit --no-verify -m "$MSG" 2>/dev/null || true
exit 0
