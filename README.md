# commitmaxxing

A Claude Code hook that reminds Claude to commit after every turn.

## Why

Claude Code knows how to commit. It just forgets. This hook reminds it.

CLAUDE.md rules work sometimes, but Claude can forget mid-session. Hooks fire every time — system-level, not memory-level.

Inspired by [@bcherny](https://x.com/bcherny) hitting 266 contributions in a single day.

## The hook

```bash
#!/usr/bin/env bash
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
echo '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes. Commit now with a descriptive message before continuing."}}'
```

That's it. It checks if you're in a git repo, then tells Claude to commit. Claude handles the rest — staging, message, the actual commit.

## Install

```bash
# Copy the hook
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

The `Stop` hook fires every time Claude finishes a response. The hook injects a message into Claude's context: "you have uncommitted changes, commit now." Claude reads that and commits with a proper descriptive message.

No staging logic. No message generation. No git gymnastics. Claude already knows how to do all of that.

## License

MIT
