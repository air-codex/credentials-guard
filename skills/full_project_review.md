# full_project_review

Run the scan and analyze the report.

## Command
```bash
./scripts/scan-full-project.sh
```

## What to do

After the scan runs, read the report output and analyze it:

1. **Identify real secrets** — API keys, passwords, tokens that are actual credentials
2. **Identify false positives** — example files, documentation, test patterns like `sk_test_FAKE`
3. **Identify at-risk patterns** — variables that look like they could hold secrets but are empty or use env vars correctly

For each finding, tell the user:
- Is it a real leak or false positive?
- What's the severity (critical / warning / safe)?
- What action to take (remove / rotate key / ignore)?

If the scan finds real leaks, offer to help clean them up.
