#!/usr/bin/env bash
# commitmaxxing — Claude Code Stop hook that nudges granular commits.
# Pure bash, no external deps (no jq).

input="$(cat)"

# 1. Loop guard — if Claude is already in forced-continuation, allow the stop.
case "$input" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

# 2. Project + git work tree
cd "${CLAUDE_PROJECT_DIR:-$PWD}" >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

git_dir="$(git rev-parse --git-dir 2>/dev/null)" || exit 0

# 3. Concurrency: don't fight a parallel git operation
[ -e "$git_dir/index.lock" ] && exit 0

# 4. Don't interrupt in-progress git operations
for m in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD REBASE_HEAD BISECT_LOG rebase-merge rebase-apply sequencer; do
  p="$(git rev-parse --git-path "$m" 2>/dev/null)" || exit 0
  [ -e "$p" ] && exit 0
done

# 5. Skip detached HEAD
git symbolic-ref -q HEAD >/dev/null 2>&1 || exit 0

# 6. Only nudge on real tracked changes (excludes untracked junk)
git status --porcelain=v1 --ignore-submodules=dirty 2>/dev/null \
  | grep -qE '^[ MADRCU]' || exit 0

# 7. Build context-aware message
msg="Uncommitted changes present. If this is a coherent checkpoint, commit with a descriptive message before stopping. If still mid-flight, keep going until a sane commit boundary."

# 7a. No GitHub remote → flag the green-squares failure mode
remote_url="$(git remote get-url origin 2>/dev/null)"
if [ -z "$remote_url" ]; then
  msg="$msg Note: no 'origin' remote configured — local commits won't sync anywhere."
elif ! printf '%s' "$remote_url" | grep -q "github.com"; then
  msg="$msg Note: 'origin' is not GitHub — commits won't appear on your GitHub contribution graph."
fi

# 7b. Unpushed commits accumulating → mention push
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
if [ -n "$upstream" ]; then
  ahead="$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
  if [ "${ahead:-0}" -ge 3 ]; then
    msg="$msg You have $ahead unpushed commits — consider pushing."
  fi
fi

# exit 2 + stderr is the documented mechanism that actually delivers text to Claude on Stop.
echo "$msg" >&2
exit 2
