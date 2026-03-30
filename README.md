<div align="center">

# Commitmaxxing Hook

**A Claude Code hook that auto-commits after every turn. Green squares don't grow themselves.**

<br />

[![Star this repo](https://img.shields.io/github/stars/longevityboris/commitmaxxing-hook?style=for-the-badge&logo=github&label=%E2%AD%90%20Star%20this%20repo&color=yellow)](https://github.com/longevityboris/commitmaxxing-hook/stargazers)
&nbsp;&nbsp;
[![Follow @longevityboris](https://img.shields.io/badge/Follow_%40longevityboris-000000?style=for-the-badge&logo=x&logoColor=white)](https://x.com/longevityboris)

<br />

[![Claude Code](https://img.shields.io/badge/Claude_Code-Hook-ff6600?style=for-the-badge&logo=anthropic&logoColor=white)](https://docs.anthropic.com/en/docs/claude-code)
[![Shell Script](https://img.shields.io/badge/Shell_Script-5_Lines-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://github.com/longevityboris/commitmaxxing-hook/blob/main/commitmaxxing.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](https://github.com/longevityboris/commitmaxxing-hook/blob/main/LICENSE)

---

Your GitHub contribution graph is a lie of omission. You code all day with Claude, but your graph stays grey because nobody commits mid-conversation. This 5-line hook fixes that. Every time Claude finishes a response, it gets one instruction: **commit now**. That's it. Your graph goes from "does this person even code?" to "someone call a doctor."

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

Done. Start a Claude Code session and watch the commits roll in.

## How It Works

The entire hook is 5 lines:

```bash
#!/usr/bin/env bash
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
echo '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes. Commit now with a descriptive message before continuing."}}'
```

1. **`Stop` hook fires** after every Claude response
2. **Checks if you're in a git repo** (exits silently if not)
3. **Injects a reminder** into Claude's context: "commit now with a descriptive message"
4. **Claude commits** because Claude knows git -- it just needs reminding

Started at 51 lines with merge conflict guards, detached HEAD checks, and porcelain status parsing. Then realized Claude already handles all of that. Deleted 46 lines.

## Features

- **5 lines of bash.** No dependencies. No config. No nonsense.
- **Works with any git repo.** If you're in a git directory, it works.
- **Smart exit.** Silently does nothing if you're not in a repo.
- **Descriptive commits.** Claude writes the commit messages, and it's actually good at it.
- **Granular history.** Every change gets its own commit. `git log` becomes useful.
- **Green squares.** The real reason you're here.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The hook is 5 lines and we'd like to keep it that way.

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
