# unstaged_review

Run the scan on unstaged changes and analyze the report.

## Command
```bash
./scripts/scan-unstaged.sh
```

## What to do

After the scan runs, read the report output and analyze it:

1. **Identify real secrets** — API keys, passwords, tokens that are actual credentials
2. **Identify false positives** — example files, documentation, test patterns
3. **Check if secrets are being added for the first time** — new files with hardcoded values

For each finding, tell the user:
- Is it a real leak or false positive?
- Should they fix it before staging?
- Suggest the fix (use env var, remove hardcoded value, etc.)

If the scan is clean, confirm it's safe to stage.
