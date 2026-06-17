#!/bin/bash
# Scan 3: Full project (all tracked files)
# For periodic audits or before releases

REPORTS_DIR="credentials/reports"
DICT_FILE="credentials/credential-patterns.txt"
REPORT_FILE="$REPORTS_DIR/full-project-$(date -u +%Y%m%d-%H%M%S).md"

echo "=== SCAN: FULL PROJECT ==="
echo ""

if [ ! -f "$DICT_FILE" ]; then
  echo "ERROR: Dictionary not found at $DICT_FILE"
  exit 1
fi

FILES=$(git ls-files | grep -v -E '\.env$|\.env\.|\.mcp\.json|node_modules/|\.next/|\.vercel/|\.git/' | grep -v -E '\.pem$|\.key$|\.cert$|\.crt$|credentials|secrets' | grep -v -E '\.example\.')

FILE_COUNT=$(echo "$FILES" | wc -w | xargs)
echo "Scanning $FILE_COUNT tracked files..."
echo ""

PATTERNS_FILE=$(mktemp)
awk '/^[[:space:]]*#/ {next} /^[[:space:]]*$/ {next} {sub(/^[[:space:]]+/,""); sub(/[[:space:]]+$/,""); print}' "$DICT_FILE" > "$PATTERNS_FILE"
PATTERN_COUNT=$(wc -l < "$PATTERNS_FILE" | xargs)
echo "Using $PATTERN_COUNT patterns"
echo ""

HAS_LEAK=0
LEAK_COUNT=0
LEAK_FILES=""
LEAK_DETAILS=""

for f in $FILES; do
  if [ ! -f "$f" ]; then
    continue
  fi
  MATCHES=$(grep -nEf "$PATTERNS_FILE" "$f" 2>/dev/null)
  if [ -n "$MATCHES" ]; then
    HAS_LEAK=1
    LEAK_COUNT=$((LEAK_COUNT + 1))
    LEAK_FILES="$LEAK_FILES- [$f](../../$f)\n"
    LEAK_DETAILS="$LEAK_DETAILS\n### [$f](../../$f)\n\`\`\`\n$MATCHES\n\`\`\`\n"
    echo "LEAK: $f"
  fi
done

rm "$PATTERNS_FILE"

mkdir -p "$REPORTS_DIR"
echo "# Full Project Scan" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$REPORT_FILE"
echo "- **Scope**: ALL tracked files" >> "$REPORT_FILE"
echo "- **Files scanned**: $FILE_COUNT" >> "$REPORT_FILE"
echo "- **Patterns used**: $PATTERN_COUNT" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$HAS_LEAK" -eq 1 ]; then
  echo "## Status: RISK FOR DATA LEAKS FOUND ($LEAK_COUNT files)" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "### Files with leaks" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo -e "$LEAK_FILES" >> "$REPORT_FILE"
  echo "### Details" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo -e "$LEAK_DETAILS" >> "$REPORT_FILE"

  echo ""
  echo "=========================================="
  echo "  SCAN COMPLETE: $LEAK_COUNT FILES WITH LEAKS"
  echo "=========================================="
  echo ""
  echo "Report: $REPORT_FILE"
else
  echo "## Status: CLEAN" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "No credential leaks detected."

  echo "=========================================="
  echo "  SCAN COMPLETE: ALL CLEAN"
  echo "=========================================="
fi
