
#!/usr/bin/env bash
# bg_move.sh — Move files to backup/ in background, print PIDs, and wait
# Usage: ./bg_move.sh <directory>

set -u
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one directory path is required."
    echo "Usage: $0 <directory>"
    exit 1
fi
DIR=$1
if [ ! -d "$DIR" ]; then
    echo "Error: $DIR is not a directory or does not exist."
    exit 1
fi
BACKUP="$DIR/backup"
mkdir -p "$BACKUP"

echo "[Script PID: $$] Starting background move operations..."; echo
for FILE in "$DIR"/*; do
    [ -d "$FILE" ] && continue
    mv "$FILE" "$BACKUP/" &
    echo "Moving $(basename "$FILE") in background (PID: $!)"
done

echo; echo "Waiting for all background processes to finish..."
wait
echo "All background operations completed."
exit 0
