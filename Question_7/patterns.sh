
#!/usr/bin/env bash
# patterns.sh — Categorize words into vowels.txt, consonants.txt, and mixed.txt

INPUT="input.txt"
if [ ! -f "$INPUT" ]; then
    echo "Error: input.txt not found."
    exit 1
fi
> vowels.txt
> consonants.txt
> mixed.txt

WORDS=$(tr -cs 'A-Za-z' '
' < "$INPUT" | tr 'A-Z' 'a-z')
for w in $WORDS; do
    if echo "$w" | grep -Eq '^[aeiou]+$'; then
        echo "$w" >> vowels.txt
        continue
    fi
    if echo "$w" | grep -Eq '^[bcdfghjklmnpqrstvwxyz]+$'; then
        echo "$w" >> consonants.txt
        continue
    fi
    if echo "$w" | grep -Eq '^[bcdfghjklmnpqrstvwxyz]' &&        echo "$w" | grep -Eq '[aeiou]' &&        echo "$w" | grep -Eq '[bcdfghjklmnpqrstvwxyz]'; then
        echo "$w" >> mixed.txt
        continue
    fi
done

echo "Processing complete. See vowels.txt, consonants.txt, mixed.txt."
exit 0
