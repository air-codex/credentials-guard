## What

Adds a pre-commit guard that scans for hardcoded secrets and credentials before they reach version control. Covers 100+ patterns including API keys, connection strings, private keys, and bearer tokens. Supports staged file scanning, full project audit, security grading, and external scanning without leaving residues.

## Why

Hardcoded secrets are one of the most common security vulnerabilities. Even after removal, credentials can be extracted from git history. SEC-02 mentions this concern but provides only advisory guidance. This guard provides active detection and blocking.

## Files

- guards/universal/check_secret_leaks.sh: Main guard script (625 lines)
- data/credential-patterns.txt: Pattern dictionary (100+ patterns)
- rules/claude-rules/common/SEC-15.md: Canonical rule
- tests/unit/test_secret_leaks.sh: Unit tests (13/13 passing)
- docs/secret-leak-detection-guard.md: Full documentation

## Usage

```bash
# Pre-commit scan
bash guards/universal/check_secret_leaks.sh

# Block on violations
bash guards/universal/check_secret_leaks.sh --strict

# Full project audit
bash guards/universal/check_secret_leaks.sh --full

# Security grading
bash guards/universal/check_secret_leaks.sh --score

# Scan external project (no residues)
bash guards/universal/check_secret_leaks.sh --external /path/to/project
```

## Type of change

- [ ] Bug fix
- [x] New feature
- [ ] Breaking change
- [ ] Documentation
- [x] New guard script

## Checklist

- [x] Tests pass (bash tests/unit/test_secret_leaks.sh)
- [x] Guard scripts tested
- [x] Documentation updated
- [x] No hardcoded paths
- [x] Conventional commit message used (feat:)

## Advice

Add data/reports/ to .gitignore to prevent committing scan reports.

## Not tested

Integration with VibeGuard pre-commit-hook flow
