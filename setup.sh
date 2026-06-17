#!/bin/bash
# credential-guard setup script
# Installs pre-commit hook and patterns to a project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

echo "=== credential-guard setup ==="
echo ""

# Check if we're in a git repo
if [ ! -d "$PROJECT_DIR/.git" ]; then
  echo "ERROR: $PROJECT_DIR is not a git repository"
  exit 1
fi

# Create credentials directory
mkdir -p "$PROJECT_DIR/credentials/reports"

# Copy hook
echo "Installing pre-commit hook..."
cp "$SCRIPT_DIR/hooks/pre-commit" "$PROJECT_DIR/.git/hooks/pre-commit"
chmod +x "$PROJECT_DIR/.git/hooks/pre-commit"

# Copy patterns if not exists
if [ ! -f "$PROJECT_DIR/credentials/credential-patterns.txt" ]; then
  echo "Creating credential patterns..."
  cp "$SCRIPT_DIR/credential-patterns.example.txt" "$PROJECT_DIR/credentials/credential-patterns.txt"
  echo "  Edit credentials/credential-patterns.txt to add your project-specific patterns"
fi

# Add to .gitignore if not already there
if ! grep -q "credentials/" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
  echo "Adding to .gitignore..."
  echo "" >> "$PROJECT_DIR/.gitignore"
  echo "# credential-guard" >> "$PROJECT_DIR/.gitignore"
  echo "credentials/" >> "$PROJECT_DIR/.gitignore"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Next steps:"
echo "  1. Edit credentials/credential-patterns.txt with your project-specific patterns"
echo "  2. Test: git add . && git commit -m 'test'"
echo "  3. Scan full project: ./scripts/scan-full-project.sh"
