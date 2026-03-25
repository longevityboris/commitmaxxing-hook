# commitmaxxing

A Claude Code hook that auto-commits after every turn — because green squares don't grow themselves.

## What

A `Stop` hook for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that automatically commits your changes after every Claude response. No more forgetting to commit. No more giant monolith commits at 2 AM.

Every time Claude finishes a turn of work, this hook:
1. Checks if you're in a git repo
2. Stages any new or modified files
3. Commits with an auto-generated message based on what changed
4. Does nothing if there are no changes (no empty commits)

## Why

Boris Cherny (creator of Claude Code) hit [266 contributions in a single day](https://x.com/bcherny/status/2036649887002153101) running Claude in auto mode. The secret? Parallel sessions + frequent commits.

But even without 10 parallel Claude sessions, you can still commitmaxx. This hook ensures **every unit of Claude work becomes a commit** — automatically, reliably, with zero effort.

CLAUDE.md rules tell Claude to commit, but Claude can forget mid-session. Hooks can't forget — they're system-level, fired by the runtime, not by Claude's memory.

## Install

### Quick (copy the hook)

```bash
# 1. Copy the hook script
curl -o ~/.claude/hooks/commitmaxxing.sh \
  https://raw.githubusercontent.com/199-biotechnologies/commitmaxxing/main/commitmaxxing.sh
chmod +x ~/.claude/hooks/commitmaxxing.sh

# 2. Add to your ~/.claude/settings.json under "hooks":
```

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/commitmaxxing.sh",
            "timeout": 15,
            "statusMessage": "commitmaxxing..."
          }
        ]
      }
    ]
  }
}
```

### If you already have Stop hooks

Add the commitmaxxing hook to your existing `Stop` hooks array:

```json
{
  "type": "command",
  "command": "bash ~/.claude/hooks/commitmaxxing.sh",
  "timeout": 15,
  "statusMessage": "commitmaxxing..."
}
```

## How it works

```
Claude responds  ──>  Stop hook fires  ──>  commitmaxxing.sh
                                                │
                                    ┌───────────┼───────────┐
                                    │           │           │
                                Not a git    No changes   Changes!
                                  repo?        found?        │
                                    │           │           │
                                  exit 0      exit 0    git add -A
                                                          │
                                                    git commit -m
                                                  "update 3 files
                                                  including App.tsx"
```

### Why Stop hook vs PostToolUse?

| Hook | Fires | Commits per turn | Noise level |
|------|-------|-----------------|-------------|
| `PostToolUse` (Write\|Edit) | After every file edit | 5-20 per turn | Extremely noisy |
| `Stop` | After Claude finishes responding | 1 per turn | Just right |
| CLAUDE.md rule | When Claude remembers | 0-1 per turn | Unreliable |

The `Stop` hook fires at **natural breakpoints** — each Claude response is typically one logical unit of work. You get one clean commit per step, not 20 "wip" commits per file edit.

## Commit messages

The hook auto-generates messages based on what changed:

| Scenario | Message |
|----------|---------|
| 1 file changed | `update App.tsx` |
| 2-5 files changed | `update 3 files including App.tsx` |
| 6+ files changed | `update 12 files` |

Want to squash later? These commit-per-turn granular commits are **perfect** for interactive rebase. Keep the history for debugging, squash for the PR.

## Pro tips

- **Squash before PR**: `git rebase -i main` to clean up the auto-commits into meaningful chunks
- **Pair with Boris's workflow**: Run multiple Claude sessions in parallel for maximum green squares
- **Works everywhere**: The hook checks for git repos, so it silently does nothing in non-git directories
- **Won't break Claude**: The `|| true` fallback ensures commit failures never block Claude's work

## The math

```
1 Claude session  x  ~20 turns/hour  =   20 commits/hour
5 parallel sessions x  20 turns/hour  =  100 commits/hour
8 hours of Claude   x 100 commits/hr  =  800 commits/day
```

Boris did 266. You can beat that.

## License

MIT. Go make your contribution graph radioactive.

---

*Inspired by [@bcherny](https://x.com/bcherny)'s 266-contribution day. Built with Claude Code, committed by Claude Code.*
