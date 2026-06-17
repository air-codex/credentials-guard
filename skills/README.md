# Credential Guard Skills

## How it works

This code runs automatically with git via the pre-commit hook. Every time you run `git commit`, the scan executes without any AI assistant involvement — saving tokens.

## Skills

| Skill | Command | When to use |
|-------|---------|-------------|
| `full_project_review` | `./scripts/scan-full-project.sh` | Periodic audit, before releases |
| `unstaged_review` | `./scripts/scan-unstaged.sh` | Before staging changes |
| `analyze_report` | `cat credentials/reports/*.md` | Quick review of scan results |

## Staged Review (Automatic)

The pre-commit hook runs automatically before every `git commit`. No skill needed, no tokens consumed.

## Connecting skills to your AI agent

If you want your AI agent to be aware of scans, you can connect these skills. However, be careful:

- **Small projects**: Safe to connect, minimal token usage
- **Large projects**: Scanning hundreds of files can consume significant tokens. The report files themselves may be large with many matches

**Recommendation**: Let git handle scans automatically. Only use skills when you need AI analysis of the results.

## Reports

All reports are saved in `credentials/reports/` with date-based filenames.
