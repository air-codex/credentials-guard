# analyze_report

Read the latest report and provide a security assessment.

## Command
```bash
cat "$(ls -t credentials/reports/*.md | head -1)"
```

## What to do

Read the report and provide a security assessment:

1. **Count real vs false positives** — how many are actual credentials vs test/example patterns?
2. **Severity rating** — are there critical leaks (production keys) or just warnings?
3. **Action items** — list specific files and lines that need cleanup
4. **Recommended next steps** — rotate keys, add to .gitignore, remove hardcoded values

Format your response as:
```
SECURITY ASSESSMENT
===================
Real leaks found: X
False positives: X
Critical: X
Warnings: X

ACTION ITEMS
------------
- [file:line] description of what to fix

SUMMARY
-------
One paragraph on overall security status.
```
