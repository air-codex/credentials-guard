# Contributing

Thanks for wanting to help make credential-guard better.

## How to contribute

1. Fork the repo
2. Create a branch (`git checkout -b my-feature`)
3. Make your changes
4. Test that scans still work (`./scripts/scan-full-project.sh`)
5. Commit and push
6. Open a PR

## What could be useful

- Better skills for AI agent integration
- New credential patterns (API keys, tokens, connection strings)
- Bug fixes
- Better report formats
- Documentation improvements

## Rules

- Keep it simple — this is a minimal security tool
- Don't add dependencies unless absolutely necessary
- Test your changes before submitting
- Follow the existing code style

## Patterns

If you're adding new credential patterns, add them to `credential-patterns.example.txt` with a comment explaining what they detect.

## Questions?

Open an issue if you're not sure about something.
