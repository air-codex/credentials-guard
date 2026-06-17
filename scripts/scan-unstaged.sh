#!/bin/bash
# Scan 1: Unstaged changes (modified but not staged)

REPORTS_DIR="credentials/reports"
DICT_FILE="credentials/credential-patterns.txt"
REPORT_FILE="$REPORTS_DIR/unstaged-$(date -u +%Y%m%d-%H%M%S).md"

echo "=== SCAN: UNSTAGED CHANGES ==="
echo ""

if [ ! -f "$DICT_FILE" ]; then
  echo "ERROR: Dictionary not found at $DICT_FILE"
  exit 1
fi

FILES=$(git diff --name-only | grep -v -E '\.env$|\.env\.|\.mcp\.json|node_modules/|\.next/|\.vercel/|\.git/' | grep -v -E '\.pem$|\.key$|\.cert$|\.crt$|credentials|secrets' | grep -v -E '\.example\.')

FILE_COUNT=$(echo "$FILES" | grep -c . 2>/dev/null || echo 0)
echo "Scanning $FILE_COUNT unstaged files..."
echo ""

if [ "$FILE_COUNT" -eq 0 ]; then
  echo "No unstaged changes."
  mkdir -p "$REPORTS_DIR"
  echo "# Unstaged Changes Scan" > "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "- **Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$REPORT_FILE"
  echo "- **Status**: NO CHANGES" >> "$REPORT_FILE"
  echo "- **Files scanned**: 0" >> "$REPORT_FILE"
  exit 0
fi

PATTERNS_FILE=$(mktemp)
awk '/^[[:space:]]*#/ {next} /^[[:space:]]*$/ {next} {sub(/^[[:space:]]+/,""); sub(/[[:space:]]+$/,""); print}' "$DICT_FILE" > "$PATTERNS_FILE"

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

mkdir -p "$SCAN_DIR"
echo "# Unstaged Changes Scan" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- **Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$REPORT_FILE"
echo "- **Scope**: Modified but NOT staged" >> "$REPORT_FILE"
echo "- **Files scanned**: $FILE_COUNT" >> "$REPORT_FILE"
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
  echo "Report: $REPORT_FILE"
else
  echo "## Status: CLEAN" >> "$REPORT_FILE"
  echo "" >> "$REPORT_FILE"
  echo "No credential leaks in unstaged changes."
fi
