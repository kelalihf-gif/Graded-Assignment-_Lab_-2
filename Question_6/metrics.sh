
#!/usr/bin/env bash
# metrics.sh — Analyze words in input.txt

set -u
INPUT="input.txt"

if [ ! -e "$INPUT" ]; then
  echo "Error: input.txt not found in the current directory."
  exit 1
fi
if [ ! -r "$INPUT" ]; then
  echo "Error: input.txt exists but is not readable."
  exit 1
fi

WORDS_FILE=$(mktemp)
trap 'rm -f "$WORDS_FILE"' EXIT

tr -cs 'A-Za-z' '
' < "$INPUT" | tr 'A-Z' 'a-z' | grep -E '.' > "$WORDS_FILE"
TOTAL_WORDS=$(wc -l < "$WORDS_FILE")
if [ "$TOTAL_WORDS" -eq 0 ]; then
  echo "No words found in input.txt."
  exit 0
fi

LONGEST=$(awk '{ if (length($0) > m) { m=length($0); w=$0 } } END { if (NR>0) print w }' "$WORDS_FILE")
SHORTEST=$(awk 'NR==1 { m=length($0); w=$0; next } { if (length($0) < m) { m=length($0); w=$0 } } END { if (NR>0) print w }' "$WORDS_FILE")
AVERAGE=$(awk '{ s+=length($0) } END { if (NR>0) printf("%.2f", s/NR) }' "$WORDS_FILE")
UNIQUE_COUNT=$(sort "$WORDS_FILE" | uniq | wc -l | tr -d '[:space:]')

echo "Longest word: $LONGEST"
echo "Shortest word: $SHORTEST"
echo "Average word length: $AVERAGE"
echo "Total unique words: $UNIQUE_COUNT"
exit 0
