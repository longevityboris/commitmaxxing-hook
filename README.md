# commitmaxxing

A Claude Code hook that makes your GitHub contribution graph look like you never sleep.

## Why

Saw [@bcherny](https://x.com/bcherny) hit 266 contributions in a single day. Looked at my graph and felt personally attacked.

So I built a hook. Is it useful for granular commit history? Sure. But let's be honest — it's mostly about the green squares.

## The hook

```bash
#!/usr/bin/env bash
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree &>/dev/null || exit 0
echo '{"hookSpecificOutput":{"hookEventName":"Stop","additionalContext":"You have uncommitted changes. Commit now with a descriptive message before continuing."}}'
```

Five lines. Every time Claude finishes a response, it gets a nudge: "commit now." Claude already knows git. It just needs reminding.

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
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

## How it works

`Stop` hook fires after every Claude response. Injects "you have uncommitted changes, commit now" into Claude's context. Claude commits. Your graph goes green.

Started at 51 lines with merge conflict guards, detached HEAD checks, and porcelain status optimisations. Then realised Claude already knows git. Deleted 46 lines.

## License

MIT. Go turn your contribution graph radioactive.
