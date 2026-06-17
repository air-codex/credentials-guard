#!/bin/bash
# Stats — scan statistics and bypass audit

echo "=== Credential Guard Stats ==="
echo ""

# 1. Scan reports
echo "[Reports]"
if [ -d "credentials/reports" ]; then
  TOTAL=$(ls credentials/reports/*.md 2>/dev/null | wc -w | xargs)
  echo "  Total reports: $TOTAL"
  
  if [ "$TOTAL" -gt 0 ]; then
    LATEST=$(ls -t credentials/reports/*.md 2>/dev/null | head -1)
    echo "  Latest: $(basename $LATEST)"
    echo "  Date: $(head -5 "$LATEST" | grep "Date" | cut -d: -f2- | xargs)"
    
    # Count leaks across all reports
    TOTAL_LEAKS=0
    for report in credentials/reports/*.md; do
      LEAKS=$(grep -c "LEAK:" "$report" 2>/dev/null)
      if [ -n "$LEAKS" ] && [ "$LEAKS" -gt 0 ] 2>/dev/null; then
        TOTAL_LEAKS=$((TOTAL_LEAKS + LEAKS))
      fi
    done
    echo "  Total leaks detected: $TOTAL_LEAKS"
  fi
else
  echo "  No reports folder found"
fi

echo ""

# 2. Bypass log
echo "[Bypass Log]"
BYPASS_LOG="credentials/scan-log.txt"
if [ -f "$BYPASS_LOG" ]; then
  BYPASS_COUNT=$(grep -c "BYPASS" "$BYPASS_LOG" 2>/dev/null || echo 0)
  echo "  Total bypasses: $BYPASS_COUNT"
  if [ "$BYPASS_COUNT" -gt 0 ]; then
    echo "  Last 5 bypasses:"
    tail -5 "$BYPASS_LOG" | while read line; do
      echo "    $line"
    done
  fi
else
  echo "  No bypasses logged"
fi

echo ""

# 3. Pattern stats
echo "[Patterns]"
PATTERN_FILE="credentials/credential-patterns.txt"
if [ -f "$PATTERN_FILE" ]; then
  TOTAL=$(grep -cve '^\s*$\|^\s*#' "$PATTERN_FILE" 2>/dev/null || echo 0)
  echo "  Total patterns: $TOTAL"
  
  # Count by category
  echo "  Categories:"
  grep "^# " "$PATTERN_FILE" | grep -v "===" | sed 's/^# /    /' | head -10
else
  echo "  No patterns file found"
fi

echo ""

# 4. Git status
echo "[Git Status]"
if [ -d ".git" ]; then
  TRACKED=$(git ls-files 2>/dev/null | wc -w | xargs)
  echo "  Tracked files: $TRACKED"
  
  # Check for potential secrets in tracked files
  POTENTIAL=$(git ls-files 2>/dev/null | xargs grep -l "password\|secret\|token\|api_key" 2>/dev/null | wc -w | tr -d ' ')
  echo "  Files with potential secrets: $POTENTIAL"
else
  echo "  Not a git repository"
fi
