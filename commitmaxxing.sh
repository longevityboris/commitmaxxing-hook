#!/usr/bin/env bash
# commitmaxxing.sh - Auto-commit after every Claude turn
# Keep it simple. Never block Claude.

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Stage, check if anything to commit, commit
git add -A 2>/dev/null || exit 0
git diff-index --quiet HEAD 2>/dev/null && exit 0

# Simple message: what changed
COUNT=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
FILE=$(git diff --cached --name-only 2>/dev/null | head -1 | xargs -I{} basename {} 2>/dev/null || echo "files")

if [ "$COUNT" -eq 1 ] 2>/dev/null; then
    git commit --no-verify -m "update $FILE" 2>/dev/null || true
else
    git commit --no-verify -m "update $COUNT files" 2>/dev/null || true
fi
