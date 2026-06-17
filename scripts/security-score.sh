#!/bin/bash
# Quality grader — rate project security based on credential exposure

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCORE=0
MAX_SCORE=100
FINDINGS=""

echo "=== Credential Guard Quality Grader ==="
echo ""

# 1. Pre-commit hook installed (20 points)
if [ -x ".git/hooks/pre-commit" ]; then
  SCORE=$((SCORE+20))
  echo -e "  ${GREEN}+20${NC} Pre-commit hook installed"
else
  echo -e "  ${RED}+0${NC}  Pre-commit hook missing"
fi

# 2. Credential patterns exist (20 points)
if [ -f "credentials/credential-patterns.txt" ]; then
  PATTERN_COUNT=$(grep -cve '^\s*$\|^\s*#' "credentials/credential-patterns.txt" 2>/dev/null || echo 0)
  if [ "$PATTERN_COUNT" -gt 50 ]; then
    SCORE=$((SCORE+20))
    echo -e "  ${GREEN}+20${NC} Credential patterns comprehensive ($PATTERN_COUNT patterns)"
  elif [ "$PATTERN_COUNT" -gt 10 ]; then
    SCORE=$((SCORE+15))
    echo -e "  ${YELLOW}+15${NC} Credential patterns basic ($PATTERN_COUNT patterns, consider adding more)"
  elif [ "$PATTERN_COUNT" -gt 0 ]; then
    SCORE=$((SCORE+10))
    echo -e "  ${YELLOW}+10${NC} Credential patterns minimal ($PATTERN_COUNT patterns)"
  else
    echo -e "  ${RED}+0${NC}  Credential patterns file empty"
  fi
else
  echo -e "  ${RED}+0${NC}  Credential patterns not found"
fi

# 3. .gitignore configured (15 points)
if grep -q "credentials/" .gitignore 2>/dev/null; then
  SCORE=$((SCORE+15))
  echo -e "  ${GREEN}+15${NC} credentials/ in .gitignore"
else
  echo -e "  ${RED}+0${NC}  credentials/ not in .gitignore"
fi

# 4. No .env files tracked (15 points)
ENV_FILES=$(git ls-files 2>/dev/null | grep -E '\.env$|\.env\.' | wc -w | xargs)
if [ "$ENV_FILES" -eq 0 ]; then
  SCORE=$((SCORE+15))
  echo -e "  ${GREEN}+15${NC} No .env files tracked in git"
else
  echo -e "  ${RED}+0${NC}  $ENV_FILES .env files tracked in git!"
  FINDINGS="$FINDINGS\n  - CRITICAL: $ENV_FILES .env files tracked in git"
fi

# 5. No private keys tracked (15 points)
KEY_FILES=$(git ls-files 2>/dev/null | grep -E '\.pem$|\.key$|\.p12$|\.pfx$' | wc -w | xargs)
if [ "$KEY_FILES" -eq 0 ]; then
  SCORE=$((SCORE+15))
  echo -e "  ${GREEN}+15${NC} No private key files tracked in git"
else
  echo -e "  ${RED}+0${NC}  $KEY_FILES private key files tracked in git!"
  FINDINGS="$FINDINGS\n  - CRITICAL: $KEY_FILES private key files tracked"
fi

# 6. Scan results (15 points)
if [ -d "credentials/reports" ]; then
  REPORT_COUNT=$(ls credentials/reports/*.md 2>/dev/null | wc -w | xargs)
  if [ "$REPORT_COUNT" -gt 0 ]; then
    LATEST=$(ls -t credentials/reports/*.md 2>/dev/null | head -1)
    if grep -q "CLEAN\|PASS" "$LATEST" 2>/dev/null; then
      SCORE=$((SCORE+15))
      echo -e "  ${GREEN}+15${NC} Latest scan: CLEAN"
    else
      LEAK_COUNT=$(grep -c "LEAK:" "$LATEST" 2>/dev/null || echo 0)
      SCORE=$((SCORE+5))
      echo -e "  ${YELLOW}+5${NC}  Latest scan: $LEAK_COUNT leaks detected"
      FINDINGS="$FINDINGS\n  - $LEAK_COUNT credential leaks found in latest scan"
    fi
  else
    echo -e "  ${YELLOW}+0${NC}  No scan reports yet"
  fi
else
  echo -e "  ${YELLOW}+0${NC}  No scan reports folder"
fi

# Grade
echo ""
echo "=== Score: $SCORE / $MAX_SCORE ==="
echo ""

if [ "$SCORE" -ge 85 ]; then
  GRADE="A"
  COLOR=$GREEN
elif [ "$SCORE" -ge 70 ]; then
  GRADE="B"
  COLOR=$GREEN
elif [ "$SCORE" -ge 55 ]; then
  GRADE="C"
  COLOR=$YELLOW
elif [ "$SCORE" -ge 40 ]; then
  GRADE="D"
  COLOR=$YELLOW
else
  GRADE="F"
  COLOR=$RED
fi

echo -e "  Grade: ${COLOR}$GRADE${NC}"

if [ -n "$FINDINGS" ]; then
  echo ""
  echo -e "${CYAN}Findings:${NC}"
  echo -e "$FINDINGS"
fi

echo ""
echo "Run ./scripts/scan-full-project.sh for a detailed scan."
