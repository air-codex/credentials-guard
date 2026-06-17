#!/bin/bash
# External scan — scan another project without leaving residues
#
# This script scans a target project for credential leaks without creating
# any files in the target directory. Reports are saved to a safe location.
#
# Usage:
# ./scripts/scan-external.sh /path/to/target
# ./scripts/scan-external.sh /path/to/target /path/to/reports

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PATTERNS_FILE="$PROJECT_DIR/credentials/credential-patterns.txt"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Arguments ---
TARGET_DIR="${1:-}"
OUTPUT_DIR="${2:-$PROJECT_DIR/credentials/reports}"

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $0 <target_dir> [output_dir]"
  echo ""
  echo "Scan another project for credential leaks."
  echo "Reports are saved to: $OUTPUT_DIR"
  echo ""
  echo "Examples:"
  echo "  $0 /path/to/other-project"
  echo "  $0 /path/to/other-project /tmp/scan-reports"
  exit 1
fi

if [[ ! -d "$TARGET_DIR" ]]; then
  echo -e "${RED}ERROR: Target directory not found: $TARGET_DIR${NC}"
  exit 1
fi

# --- Setup ---
REPORTS_DIR="$OUTPUT_DIR"
mkdir -p "$REPORTS_DIR"
REPORT_FILE="$REPORTS_DIR/external-$(basename "$TARGET_DIR")-$(date -u +%Y%m%d-%H%M%S).md"

# --- Pattern Loading ---
if [[ ! -f "$PATTERNS_FILE" ]]; then
  echo -e "${YELLOW}WARNING: Pattern dictionary not found at $PATTERNS_FILE${NC}"
  echo "Using built-in patterns only."
  PATTERNS=(
    "sk-[a-zA-Z0-9]{20,}"
    "sk-ant-[a-zA-Z0-9]{20,}"
    "AIza[a-zA-Z0-9_-]{35}"
    "AKIA[a-zA-Z0-9]{16}"
    "ghp_[a-zA-Z0-9]{36}"
    "postgresql://[^:]+:[^@]+@"
    "mysql://[^:]+:[^@]+@"
    "mongodb(\+srv)?://[^:]+:[^@]+@"
    "redis://[^:]+:[^@]+@"
    "Bearer [a-zA-Z0-9._~+/=-]{20,}"
    "eyJ[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}\.[a-zA-Z0-9_-]{20,}"
    "BEGIN (RSA |EC |DSA |OPENSSH |PGP )?PRIVATE KEY"
  )
  PATTERN_COUNT=${#PATTERNS[@]}
else
  # Load patterns from file
  TMP_PATTERNS=$(mktemp)
  awk '/^[[:space:]]*#/ {next} /^[[:space:]]*$/ {next} {sub(/^[[:space:]]+/,""); sub(/[[:space:]]+$/,""); print}' "$PATTERNS_FILE" > "$TMP_PATTERNS"
  PATTERN_COUNT=$(wc -l < "$TMP_PATTERNS" | xargs)
fi

echo -e "${CYAN}=== External Credential Scan ===${NC}"
echo ""
echo "Target: $TARGET_DIR"
echo "Patterns: $PATTERN_COUNT"
echo "Report: $REPORT_FILE"
echo ""

# --- Find files ---
FILES=$(cd "$TARGET_DIR" && git ls-files 2>/dev/null | grep -v -E '\.env$|\.env\.|\.mcp\.json|node_modules/|\.next/|\.vercel/|\.git/' | grep -v -E '\.pem$|\.key$|\.cert$|\.crt$|credentials|secrets' | grep -v -E '\.example\.' || true)

if [[ -z "$FILES" ]]; then
  # Fall back to find if not a git repo
  FILES=$(cd "$TARGET_DIR" && find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/dist/*" -not -path "*/build/*" -not -name "*.env" -not -name "*.env.*" -not -name "*.pem" -not -name "*.key" 2>/dev/null | head -1000)
fi

FILE_COUNT=$(echo "$FILES" | wc -w | xargs)
echo -e "${CYAN}Scanning $FILE_COUNT files...${NC}"
echo ""

# --- Scan ---
HAS_LEAK=0
LEAK_COUNT=0
LEAK_FILES=""
LEAK_DETAILS=""

for f in $FILES; do
  # Handle relative paths
  if [[ -f "$TARGET_DIR/$f" ]]; then
    FULL_PATH="$TARGET_DIR/$f"
  elif [[ -f "$f" ]]; then
    FULL_PATH="$f"
  else
    continue
  fi

  # Skip binary files
  if file --mime-encoding "$FULL_PATH" 2>/dev/null | grep -q "binary"; then
    continue
  fi

  # Search for patterns
  if [[ -f "${TMP_PATTERNS:-}" ]]; then
    MATCHES=$(grep -nEf "$TMP_PATTERNS" "$FULL_PATH" 2>/dev/null || true)
  else
    MATCHES=""
    for pattern in "${PATTERNS[@]}"; do
      PATTERN_MATCHES=$(grep -nE "$pattern" "$FULL_PATH" 2>/dev/null || true)
      if [[ -n "$PATTERN_MATCHES" ]]; then
        MATCHES="${MATCHES}${PATTERN_MATCHES}\n"
      fi
    done
    MATCHES=$(echo -e "$MATCHES" | sed '/^$/d')
  fi

  if [[ -n "$MATCHES" ]]; then
    HAS_LEAK=1
    LEAK_COUNT=$((LEAK_COUNT + 1))
    LEAK_FILES="$LEAK_FILES- \`$f\`\n"
    LEAK_DETAILS="$LEAK_DETAILS\n### \`$f\`\n\`\`\`\n$MATCHES\n\`\`\`\n"
    echo -e "${RED}LEAK: $f${NC}"
  fi
done

# Cleanup
[[ -f "${TMP_PATTERNS:-}" ]] && rm "$TMP_PATTERNS"

# --- Generate report ---
{
  echo "# External Credential Scan"
  echo ""
  echo "- **Date**: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "- **Target**: \`$TARGET_DIR\`"
  echo "- **Files scanned**: $FILE_COUNT"
  echo "- **Patterns used**: $PATTERN_COUNT"
  echo ""

  if [[ "$HAS_LEAK" -eq 1 ]]; then
    echo "## Status: RISK FOR DATA LEAKS FOUND ($LEAK_COUNT files)"
    echo ""
    echo "### Files with leaks"
    echo ""
    echo -e "$LEAK_FILES"
    echo "### Details"
    echo ""
    echo -e "$LEAK_DETAILS"
  else
    echo "## Status: CLEAN"
    echo ""
    echo "No credential leaks detected."
  fi
} > "$REPORT_FILE"

# --- Summary ---
echo ""
if [[ "$HAS_LEAK" -eq 1 ]]; then
  echo -e "${RED}=========================================="
  echo "  SCAN COMPLETE: $LEAK_COUNT FILES WITH LEAKS"
  echo "==========================================${NC}"
  echo ""
  echo "Report: $REPORT_FILE"
  exit 1
else
  echo -e "${GREEN}=========================================="
  echo "  SCAN COMPLETE: ALL CLEAN"
  echo "==========================================${NC}"
  echo ""
  echo "Report: $REPORT_FILE"
  exit 0
fi
