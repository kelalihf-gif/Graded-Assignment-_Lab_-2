
#!/usr/bin/env bash
# emailcleaner.sh — Extract valid/invalid emails and deduplicate valid list
# Valid format: <letters_and_digits>@<letters>.com

INPUT="emails.txt"

if [ ! -f "$INPUT" ]; then
    echo "Error: emails.txt not found in the current directory."
    exit 1
fi

# Extract valid emails
grep -E '^[A-Za-z0-9]+@[A-Za-z]+\.com$' "$INPUT" > valid_raw.txt
sort valid_raw.txt | uniq > valid.txt
rm -f valid_raw.txt

# Extract invalid emails (non-matching)
grep -vE '^[A-Za-z0-9]+@[A-Za-z]+\.com$' "$INPUT" > invalid.txt

echo "Processing complete. See valid.txt and invalid.txt."
exit 0
