<div align="center">

# Commitmaxxing Hook

**A Claude Code hook that nudges granular commits after every turn. Green squares don't grow themselves.**

<br />

[![Star this repo](https://img.shields.io/github/stars/longevityboris/commitmaxxing-hook?style=for-the-badge&logo=github&label=%E2%AD%90%20Star%20this%20repo&color=yellow)](https://github.com/longevityboris/commitmaxxing-hook/stargazers)
&nbsp;&nbsp;
[![Follow @longevityboris](https://img.shields.io/badge/Follow_%40longevityboris-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/longevityboris)

<br />

[![Claude Code](https://img.shields.io/badge/Claude_Code-Stop_Hook-ff6600?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.claude.com/en/docs/claude-code)
[![Pure Bash](https://img.shields.io/badge/Pure_Bash-Zero_Deps-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/longevityboris/commitmaxxing-hook/blob/main/commitmaxxing.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](https://github.com/longevityboris/commitmaxxing-hook/blob/main/LICENSE)

---

Your GitHub contribution graph is a lie of omission. You code all day with Claude, but your graph stays grey because nobody commits mid-conversation. This hook fixes that. Every time Claude finishes a response, it gets one instruction: **commit now**. That's it. Your graph goes from "does this person even code?" to "someone call a doctor."

[Install](#install) | [How It Works](#how-it-works) | [Features](#features) | [Contributing](#contributing)

</div>

## Why This Exists

[@bcherny](https://x.com/bcherny) hit 266 contributions in a single day. I looked at my contribution graph and felt personally attacked.

The problem is simple: you're coding with Claude Code for hours, making real progress, but your GitHub graph doesn't know that. Commits pile up in your working tree. You push once at the end of the day. GitHub thinks you worked for 5 minutes.

This hook turns every Claude interaction into a commit. Is it useful for granular commit history? Sure. But let's be honest -- it's mostly about the green squares.

## Before vs After

```
BEFORE (sad, grey, concerning)
  Mon  . . . . . . . . . . . .
  Wed  . . . . # . . . . . . .
  Fri  . . . . . . . . . . . .

AFTER (commitmaxxing)
  Mon  # # # # # # # # # # # #
  Wed  # # # # # # # # # # # #
  Fri  # # # # # # # # # # # #
```

Same amount of work. Different graph. Different you.

## Install

**1. Download the hook:**

```bash
mkdir -p ~/.claude/hooks
curl -o ~/.claude/hooks/commitmaxxing.sh \
  https://raw.githubusercontent.com/longevityboris/commitmaxxing-hook/main/commitmaxxing.sh
chmod +x ~/.claude/hooks/commitmaxxing.sh
```

**2. Add to `~/.claude/settings.json`:**

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/commitmaxxing.sh",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

If you use agent teams, register the same script under `SubagentStop` too.

Done. Start a Claude Code session and watch the commits roll in.

## How It Works

`Stop` hook fires after every Claude response. The script delivers its message via `exit 2` + `stderr` — the documented path that actually injects feedback into Claude's context for `Stop` events. Claude sees "uncommitted changes present, commit before stopping" and commits. Your graph goes green.

```bash
#!/usr/bin/env bash
input="$(cat)"

# Loop guard — Claude Code's stop_hook_active flag prevents infinite re-entry.
case "$input" in
  *'"stop_hook_active":true'*|*'"stop_hook_active": true'*) exit 0 ;;
esac

cd "${CLAUDE_PROJECT_DIR:-$PWD}" >/dev/null 2>&1 || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git_dir="$(git rev-parse --git-dir 2>/dev/null)" || exit 0

# Don't fight a parallel git op or interrupt in-progress git states.
[ -e "$git_dir/index.lock" ] && exit 0
for m in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD REBASE_HEAD BISECT_LOG rebase-merge rebase-apply sequencer; do
  p="$(git rev-parse --git-path "$m" 2>/dev/null)" || exit 0
  [ -e "$p" ] && exit 0
done

# Skip detached HEAD; only nudge on real tracked changes (no untracked junk).
git symbolic-ref -q HEAD >/dev/null 2>&1 || exit 0
git status --porcelain=v1 --ignore-submodules=dirty 2>/dev/null \
  | grep -qE '^[ MADRCU]' || exit 0

msg="Uncommitted changes present. If this is a coherent checkpoint, commit with a descriptive message before stopping. If still mid-flight, keep going until a sane commit boundary."

# Surface green-squares failure modes.
remote_url="$(git remote get-url origin 2>/dev/null)"
if [ -z "$remote_url" ]; then
  msg="$msg Note: no 'origin' remote configured — local commits won't sync anywhere."
elif ! printf '%s' "$remote_url" | grep -q "github.com"; then
  msg="$msg Note: 'origin' is not GitHub — commits won't appear on your GitHub contribution graph."
fi

# Nudge to push when commits accumulate locally.
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"
if [ -n "$upstream" ]; then
  ahead="$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo 0)"
  if [ "${ahead:-0}" -ge 3 ]; then
    msg="$msg You have $ahead unpushed commits — consider pushing."
  fi
fi

echo "$msg" >&2
exit 2
```

### A note on the original 5-line version

This started as five lines. Those five lines printed JSON with `hookSpecificOutput.additionalContext` — and `additionalContext` is only valid for `UserPromptSubmit` and `SessionStart` hooks. For `Stop`, Claude Code silently drops it. So the original version was advertising a behavior it never delivered.

The current version uses `exit 2 + stderr`, which is the documented mechanism for `Stop` per the [hooks reference](https://code.claude.com/docs/en/hooks). The extra lines are guards, not features — and most of them are early-exits, so the script does nothing in 99% of states.

## Features

- **Pure bash, zero dependencies.** No `jq`, no Python.
- **Loop-safe.** Honors `stop_hook_active` so it never traps Claude in an infinite stop loop.
- **Workflow-safe.** Stays silent during rebase, merge, cherry-pick, revert, bisect, sequencer state, detached HEAD, or `.git/index.lock` contention.
- **Quiet on clean trees.** Only nudges when there are real tracked changes — never on untracked junk alone.
- **Green-squares aware.** Warns when `origin` is missing or non-GitHub (so you know your graph won't fill).
- **Push-aware.** Suggests pushing once 3+ unpushed commits accumulate.
- **Descriptive commits.** Claude writes the messages — and Claude is good at it.

## What it guards against

| Case | Behavior |
|---|---|
| Clean tree | silent (no nudge) |
| Only untracked files | silent (no junk commits) |
| Mid-rebase / merge / cherry-pick / bisect / revert | silent (no interference) |
| Detached HEAD | silent (no orphan commits) |
| `.git/index.lock` present | silent (no race with concurrent git) |
| Empty repo (no HEAD yet) | silent |
| Outside any git repo | silent |
| `stop_hook_active=true` | silent (no infinite loop) |
| Tracked changes + GitHub remote | nudge to commit |
| Tracked changes + no remote | nudge + warn local-only |
| Tracked changes + non-GitHub remote | nudge + warn no green squares |
| 3+ unpushed commits | nudge + suggest push |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Improvements welcome — especially edge cases this script doesn't handle yet.

## License

[MIT](LICENSE). Go turn your contribution graph radioactive.

---

<div align="center">

Built by [Boris Djordjevic](https://github.com/longevityboris) at [199 Biotechnologies](https://github.com/199-biotechnologies) | [Paperfoot AI](https://paperfoot.ai)

<br />

**If this is useful to you:**

[![Star this repo](https://img.shields.io/github/stars/longevityboris/commitmaxxing-hook?style=for-the-badge&logo=github&label=%E2%AD%90%20Star%20this%20repo&color=yellow)](https://github.com/longevityboris/commitmaxxing-hook/stargazers)
&nbsp;&nbsp;
[![Follow @longevityboris](https://img.shields.io/badge/Follow_%40longevityboris-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/longevityboris)

</div>
