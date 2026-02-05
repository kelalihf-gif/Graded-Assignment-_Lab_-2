
#!/usr/bin/env bash
# validate_results.sh — Process student exam results from marks.txt
# Format: RollNo,Name,Marks1,Marks2,Marks3

FILE="marks.txt"

if [ ! -f "$FILE" ]; then
    echo "Error: marks.txt not found in the current directory."
    exit 1
fi

echo "Students who failed in exactly ONE subject:"
echo "-------------------------------------------"

fail_one_count=0
pass_all_count=0

while IFS=',' read -r roll name m1 m2 m3; do
    [ -z "$roll" ] && continue
    fail_count=0
    [ "$m1" -lt 33 ] && fail_count=$((fail_count + 1))
    [ "$m2" -lt 33 ] && fail_count=$((fail_count + 1))
    [ "$m3" -lt 33 ] && fail_count=$((fail_count + 1))

    if [ "$fail_count" -eq 1 ]; then
        echo "$roll — $name"
        fail_one_count=$((fail_one_count + 1))
    fi
    if [ "$fail_count" -eq 0 ]; then
        pass_all_count=$((pass_all_count + 1))
    fi

done < "$FILE"

echo ""
echo "Students who passed ALL subjects:"
echo "---------------------------------"
echo "$pass_all_count students"

echo ""
echo "Summary:"
echo "--------"
echo "Failed exactly one subject: $fail_one_count"
echo "Passed all subjects:        $pass_all_count"

exit 0
