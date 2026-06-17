# Scripts

## Scan Scripts

### scan-unstaged.sh
Scans modified but NOT staged files. Run before `git add` to catch leaks early.

```bash
./scripts/scan-unstaged.sh
```

### scan-staged.sh
Scans files ready to commit. Run after `git add` to verify before commit.

```bash
./scripts/scan-staged.sh
```

### scan-full-project.sh
Scans ALL tracked files in the project. Use for periodic audits or after installing.

```bash
./scripts/scan-full-project.sh
```

All scan scripts save reports in `credentials/reports/` with date-based filenames.

## Observability Scripts

### check-install.sh
Verifies credential-guard is installed and working. Checks:
- Git repository
- Pre-commit hook installed and executable
- Credential patterns loaded
- Scan scripts ready
- .gitignore configured

```bash
./scripts/check-install.sh
```

Exit codes: 0 = HEALTHY, 1 = DEGRADED, 2 = BROKEN

### security-score.sh
Rates project security from A to F based on:
- Pre-commit hook (20 pts)
- Credential patterns (20 pts)
- .gitignore config (15 pts)
- No .env files tracked (15 pts)
- No private keys tracked (15 pts)
- Latest scan results (15 pts)

```bash
./scripts/security-score.sh
```

### stats.sh
Shows scan statistics:
- Total reports and latest scan date
- Total leaks detected
- Bypass audit log
- Pattern count and categories
- Git tracked files and potential secrets

```bash
./scripts/stats.sh
```

## Bypass

When the pre-commit hook blocks a commit, it's because it detected something that looks like a credential. Before bypassing, you must review the report to confirm it's a false positive.

**When to bypass:**
- The detected "secrets" are example values in documentation
- The detected patterns are test fixtures or placeholder values
- The detected keys are in README files explaining how to use credentials

**When NOT to bypass:**
- Real API keys, passwords, or tokens in source code
- Database connection strings with real credentials
- Private keys or certificates

**How to bypass:**

1. Read the report:
```bash
cat "$(ls -t credentials/reports/*.md | head -1)"
```

2. Confirm all findings are false positives

3. Create bypass file and commit:
```bash
touch credentials/bypass-scan
git commit
```

The bypass is logged in `credentials/scan-log.txt` for audit purposes. Never bypass without reviewing first.
