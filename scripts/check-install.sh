#!/bin/bash
# Health check — verify credential-guard is installed and working

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
WARN=0
FAIL=0

check_pass() { echo -e "  ${GREEN}✓${NC} $1"; PASS=$((PASS+1)); }
check_warn() { echo -e "  ${YELLOW}!${NC} $1"; WARN=$((WARN+1)); }
check_fail() { echo -e "  ${RED}✗${NC} $1"; FAIL=$((FAIL+1)); }

echo "=== Credential Guard Health Check ==="
echo ""

# 1. Check git repo
echo "[Git Repository]"
if [ -d ".git" ]; then
  check_pass "Git repository detected"
else
  check_fail "Not a git repository"
fi

# 2. Check pre-commit hook
echo "[Pre-commit Hook]"
HOOK_PATH=".git/hooks/pre-commit"
if [ -f "$HOOK_PATH" ]; then
  if [ -x "$HOOK_PATH" ]; then
    check_pass "Pre-commit hook installed and executable"
  else
    check_warn "Pre-commit hook exists but not executable (chmod +x $HOOK_PATH)"
  fi
else
  check_fail "Pre-commit hook not found at $HOOK_PATH"
fi

# 3. Check credential patterns
echo "[Credential Patterns]"
PATTERN_FILE="credentials/credential-patterns.txt"
if [ -f "$PATTERN_FILE" ]; then
  PATTERN_COUNT=$(grep -cve '^\s*$\|^\s*#' "$PATTERN_FILE" 2>/dev/null || echo 0)
  if [ "$PATTERN_COUNT" -gt 0 ]; then
    check_pass "Credential patterns loaded ($PATTERN_COUNT patterns)"
  else
    check_warn "Credential patterns file exists but has no active patterns"
  fi
else
  check_fail "Credential patterns not found at $PATTERN_FILE"
fi

# 4. Check example patterns
echo "[Example Patterns]"
if [ -f "credential-patterns.example.txt" ]; then
  check_pass "Example patterns available"
else
  check_warn "Example patterns not found"
fi

# 5. Check scan scripts
echo "[Scan Scripts]"
for script in scan-unstaged.sh scan-staged.sh scan-full-project.sh; do
  if [ -x "scripts/$script" ]; then
    check_pass "scripts/$script ready"
  elif [ -f "scripts/$script" ]; then
    check_warn "scripts/$script exists but not executable"
  else
    check_fail "scripts/$script not found"
  fi
done

# 6. Check credentials folder
echo "[Credentials Folder]"
if [ -d "credentials" ]; then
  check_pass "credentials/ folder exists"
else
  check_warn "credentials/ folder not found (run setup first)"
fi

# 7. Check .gitignore
echo "[Gitignore]"
if grep -q "credentials/" .gitignore 2>/dev/null; then
  check_pass "credentials/ in .gitignore"
else
  check_warn "credentials/ not in .gitignore (add it to avoid committing secrets)"
fi

# 8. Quick scan test
echo "[Quick Scan Test]"
OUTPUT=$(./scripts/scan-full-project.sh 2>&1)
if echo "$OUTPUT" | grep -q "SCAN COMPLETE"; then
  check_pass "Full project scan works"
else
  check_fail "Full project scan failed"
fi

# Summary
echo ""
echo "=== Summary ==="
echo -e "  ${GREEN}Passed: $PASS${NC}"
echo -e "  ${YELLOW}Warnings: $WARN${NC}"
echo -e "  ${RED}Failed: $FAIL${NC}"
echo ""

if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}HEALTHY${NC} — Credential guard is operational"
  exit 0
elif [ "$FAIL" -le 2 ]; then
  echo -e "${YELLOW}DEGRADED${NC} — Some issues detected, check warnings"
  exit 1
else
  echo -e "${RED}BROKEN${NC} — Critical issues found, reinstall recommended"
  exit 2
fi
