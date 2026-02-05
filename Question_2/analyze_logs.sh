
#!/usr/bin/env bash
# analyze_logs.sh — Log analyzer script
# Usage: ./analyze_logs.sh <logfile>

set -u

if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument (log file name) is required."
    echo "Usage: $0 <logfile>"
    exit 1
fi

LOGFILE=$1

if [ ! -e "$LOGFILE" ]; then
    echo "Error: File does not exist: $LOGFILE"
    exit 1
fi

if [ ! -r "$LOGFILE" ]; then
    echo "Error: File exists but is not readable: $LOGFILE"
    exit 1
fi

TOTAL=$(wc -l < "$LOGFILE")
INFO_COUNT=$(grep -c " INFO " "$LOGFILE" || true)
WARNING_COUNT=$(grep -c " WARNING " "$LOGFILE" || true)
ERROR_COUNT=$(grep -c " ERROR " "$LOGFILE" || true)

LAST_ERROR=$(grep " ERROR " "$LOGFILE" | tail -n 1)
[ -z "$LAST_ERROR" ] && LAST_ERROR="No ERROR entries found in the log."

TODAY=$(date +%Y-%m-%d)
REPORT="logsummary_${TODAY}.txt"

{
    echo "Log Summary Report — $TODAY"
    echo "=============================="
    echo "Log File: $LOGFILE"
    echo ""
    echo "Total log entries: $TOTAL"
    echo "INFO messages: $INFO_COUNT"
    echo "WARNING messages: $WARNING_COUNT"
    echo "ERROR messages: $ERROR_COUNT"
    echo ""
    echo "Most recent ERROR entry:"
    echo "$LAST_ERROR"
} > "$REPORT"

echo "Report generated: $REPORT"
exit 0
