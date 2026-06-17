# Security Directory

Local security configuration for credential leak prevention.

**Warning**: The `credentials/` folder contains your local patterns and scan reports. It should NOT be committed to version control. Add it to `.gitignore` in production:

```bash
echo "credentials/" >> .gitignore
```

## Structure

| Path | Purpose | Committed? |
|------|---------|------------|
| `credential-patterns.example.txt` | Example patterns (reference) | **Yes** |
| `credentials/credential-patterns.txt` | Your local patterns | **No** (gitignore) |
| `credentials/reports/` | Scan reports with dates | **No** (gitignore) |
| `hooks/pre-commit` | Pre-commit hook script | **Yes** |
| `scripts/scan-*.sh` | Manual scan scripts | **Yes** |
| `credentials/bypass-scan` | Bypass file (temporary) | **No** (gitignore) |
| `credentials/scan-log.txt` | Bypass audit log | **No** (gitignore) |

## Pre-commit Hook

### What it does
Runs automatically before every `git commit`. Scans staged files for credential patterns. Blocks commit if leaks detected.

### How it works
1. Reads patterns from `credentials/credential-patterns.txt`
2. Scans staged file contents against patterns
3. If match found → commit BLOCKED
4. Report saved to `credentials/reports/pre-commit-YYYYMMDD-HHMMSS.md`

### Bypass
```bash
touch credentials/bypass-scan
git commit
```

Bypass is logged in `credentials/scan-log.txt`.

## Manual Scans

```bash
# Scan unstaged changes
./scripts/scan-unstaged.sh

# Scan staged changes
./scripts/scan-staged.sh

# Scan full project
./scripts/scan-full-project.sh

# Scan external project (no residues in target)
./scripts/scan-external.sh /path/to/project
./scripts/scan-external.sh /path/to/project /path/to/reports
```

Reports are saved in `credentials/reports/` with date-based filenames.

### External Scan

The `scan-external.sh` script scans other projects without creating any files in the target directory. Reports are saved to a safe location (default: `credentials/reports/`).

```bash
# Scan another project
./scripts/scan-external.sh /path/to/other-project

# Save reports to specific location
./scripts/scan-external.sh /path/to/other-project /tmp/scan-reports
```

## Setup for New Team Members

```bash
# 1. Copy example patterns
cp credential-patterns.example.txt credentials/credential-patterns.txt

# 2. Add your project-specific patterns
# Edit credentials/credential-patterns.txt

# 3. Add credentials/ to .gitignore
echo "credentials/" >> .gitignore
```
