# Changelog

## [0.2.0] - 2026-06-17

### Added
- External scan script (`scan-external.sh`) for auditing other projects without leaving residues
- Reports saved to `credentials/reports/` without creating files in target directory
- VibeGuard contribution files in `vibeguard-contribution/`

### Changed
- Updated `.gitignore` to exclude banner design assets (`docs/assets/*.html`, `docs/assets/*.css`)

## [0.1.0] - 2026-06-16

### Added
- Pre-commit hook that blocks commits with hardcoded secrets
- 143+ credential patterns (API keys, cloud providers, tokens, connection strings)
- Scan scripts: unstaged, staged, full project
- Markdown reports with clickable file links and line numbers
- Bypass mechanism with audit logging
- Health check script (`check-install.sh`)
- Security score script (`security-score.sh`)
- Stats script for scan statistics
- Skills for AI agent integration (full_project_review, unstaged_review, analyze_report)
- Claude slash commands (`/cg:scan`, `/cg:score`, `/cg:check`, `/cg:report`)
- CLAUDE.md with credential security rules (in `.claude/` folder)
- Setup script for new projects
- Test files with fake secrets for demo
- CHANGELOG.md
- CONTRIBUTING.md
- Scanner is scalable — add any pattern to the template and it catches it

### Fixed
- Generate report when blocking sensitive files by name
- Show project name instead of user in reports and logs
- Use relative paths in report links
- List scanned files in reports instead of just a count
- Bypass generates its own report with BYPASS status
- Skip example files (`*.example.*`) in content scan
- Removed user info from scan logs (no `whoami` anywhere)

### Changed
- Reports saved in `credentials/reports/` with date-based filenames
- Restructured to `credentials/` folder (patterns + reports)
- `.gitignore` has `credentials/` entries commented as a guide (not active)
- README warns that READMEs must never be excluded from audit
