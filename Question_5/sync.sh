
#!/usr/bin/env bash
# sync.sh — Compare two directories without modifying them.
# Usage: ./sync.sh dirA dirB

set -u

if [ "$#" -ne 2 ]; then
    echo "Error: Exactly two directory paths are required."
    echo "Usage: $0 <dirA> <dirB>"
    exit 1
fi

DIRA=$1
DIRB=$2

if [ ! -d "$DIRA" ]; then
    echo "Error: $DIRA is not a directory or does not exist."
    exit 1
fi

if [ ! -d "$DIRB" ]; then
    echo "Error: $DIRB is not a directory or does not exist."
    exit 1
fi

echo "Files only in $DIRA:"
echo "----------------------"
comm -23 <(ls -1 "$DIRA" | sort) <(ls -1 "$DIRB" | sort)
echo ""

echo "Files only in $DIRB:"
echo "----------------------"
comm -13 <(ls -1 "$DIRA" | sort) <(ls -1 "$DIRB" | sort)
echo ""

echo "Files present in BOTH directories (content comparison):"
echo "--------------------------------------------------------"
COMMON=$(comm -12 <(ls -1 "$DIRA" | sort) <(ls -1 "$DIRB" | sort))
if [ -z "$COMMON" ]; then
    echo "No files with matching names in both directories."
    exit 0
fi
for file in $COMMON; do
    if cmp -s "$DIRA/$file" "$DIRB/$file"; then
        echo "$file : MATCH"
    else
        echo "$file : DIFFER"
    fi
done

exit 0
