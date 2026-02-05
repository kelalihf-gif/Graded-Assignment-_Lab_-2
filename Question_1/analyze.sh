
#!/usr/bin/env bash
# analyze.sh — Analyze a single file or directory
# Usage: ./analyze.sh <path>

set -u

if [ "$#" -ne 1 ]; then
  echo "Error: Exactly one argument is required."
  echo "Usage: $0 <file-or-directory>"
  exit 1
fi

TARGET=$1

if [ ! -e "$TARGET" ]; then
  echo "Error: Path does not exist: $TARGET"
  exit 1
fi

if [ -f "$TARGET" ]; then
  LINES=$(wc -l < "$TARGET")
  WORDS=$(wc -w < "$TARGET")
  CHARS=$(wc -m < "$TARGET")
  echo "File: $TARGET"
  echo "Lines: $LINES"
  echo "Words: $WORDS"
  echo "Characters: $CHARS"
  exit 0
fi

if [ -d "$TARGET" ]; then
  echo "Directory: $TARGET"
  TOTAL_FILES=$(find "$TARGET" -maxdepth 1 -type f | wc -l | tr -d ' ')
  echo "Total files (non-recursive): $TOTAL_FILES"
  TXT_FILES=$(find "$TARGET" -maxdepth 1 -type f -iname "*.txt" | wc -l | tr -d ' ')
  echo "Number of .txt files (non-recursive): $TXT_FILES"
  exit 0
fi

echo "Error: Path exists but is neither a regular file nor a directory."
exit 1
