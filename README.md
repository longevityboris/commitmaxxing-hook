# commitmaxxing

A Claude Code hook that reminds Claude to commit after every turn. Because green squares don't grow themselves.

## Why

Saw [@bcherny](https://x.com/bcherny) hit 266 contributions in a single day. Looked at my contribution graph and felt personally attacked.

Claude Code knows how to commit. It just forgets. CLAUDE.md rules work sometimes, but mid-session Claude's memory is basically a goldfish. Hooks fire every time — system-level, not memory-level. Can't forget if the system won't let you.

## The hook

```bash
#!/usr/bin/env bash
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
echo '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes. Commit now with a descriptive message before continuing."}}'
```

That's it. Five lines. It checks if you're in a git repo, then tells Claude to commit. Claude handles the rest — staging, message, the actual commit. No git gymnastics. Claude already knows how to use git; it just needs a nudge.

## Install

```bash
curl -o ~/.claude/hooks/commitmaxxing.sh \
  https://raw.githubusercontent.com/longevityboris/commitmaxxing-hook/main/commitmaxxing.sh
chmod +x ~/.claude/hooks/commitmaxxing.sh
```

Add to `~/.claude/settings.json`:

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
            "async": true
          }
        ]
      }
    ]
  }
}
```

If you already have Stop hooks, just add the hook object to your existing array.

## How it works

The `Stop` hook fires every time Claude finishes a response. The hook injects a reminder into Claude's context: "you have uncommitted changes, commit now." Claude reads that and commits properly.

We went through four iterations to get here. Started with a 51-line script that handled merge conflicts, detached HEADs, bisect state, porcelain status checks, and filenames with spaces. Then realised: Claude already knows all of that. The hook doesn't need to be a git tutorial. It just needs to say "oi, commit."

## License

MIT. Go make your contribution graph radioactive.
