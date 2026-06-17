# credential-guard

This project scans code for hardcoded secrets and blocks commits that would leak credentials.

## How to work with this code

- Never add real API keys, passwords, or tokens to any file — use environment variables
- .env files must stay out of git — add them to .gitignore
- Don't put realistic-looking credentials in comments as examples — use obviously fake values
- When you add a new env var to the project, add its pattern to `credentials/credential-patterns.txt`
- If you discover a leaked credential in the code, rotate the key immediately — just removing it from code is not enough
- The `credentials/` folder and everything inside it must never be committed — always add it to .gitignore
- `credentials/credential-patterns.txt` is your local config, never commit it

## Working with scans

- Run `./scripts/scan-full-project.sh` to check the entire project
- Run `./scripts/check-install.sh` to verify everything is installed correctly
- Run `./scripts/security-score.sh` to get a security grade
- Scan reports go to `credentials/reports/` — never commit that folder
- If the pre-commit hook blocks you, check the report to understand why before bypassing

## Reviewing reports

- Lines marked `LEAK:` are detected credentials
- Some will be false positives (test keys, examples, documentation) — that's normal
- Real leaks need immediate action: remove from code and rotate the key
- False positives can be ignored, but consider if the pattern should be excluded

## Customization

- Edit `credentials/credential-patterns.txt` to add your project's specific env var names
- The more specific your patterns, the fewer false positives you'll get
- Generic patterns catch common leaks across all projects
