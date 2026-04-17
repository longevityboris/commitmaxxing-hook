# Contributing

Want to make the hook even better? Great.

## How to contribute

1. Fork the repo
2. Create a branch (`git checkout -b my-improvement`)
3. Make your changes
4. Test that the hook still works with Claude Code
5. Commit with a descriptive message
6. Open a PR

## What we're looking for

- Bug fixes
- Better commit message heuristics
- Support for more AI coding tools
- Documentation improvements

## What we're not looking for

- Dependencies. It's a pure bash script — let's keep it that way (no `jq`, no Python).
- Cleverness over correctness. If a guard is needed for a real edge case, it earns its lines.
- Auto-pushing. Pushing is destructive enough to stay an explicit decision.

## Code style

Keep it minimal but correct. Every line should pay for itself — either by handling a real failure mode (rebase, lock file, detached HEAD, infinite loop) or by improving the message Claude sees. No speculative guards for cases that can't happen.

When adding an edge case, also add a test scenario in the PR description (e.g. "tested by creating `.git/index.lock` then running the hook with sample stdin").

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
