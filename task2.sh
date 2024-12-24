#!/bin/bash

# Provera da li je putanja do output.txt prosleđena kao argument
if [ $# -lt 1 ]; then
    echo "Usage: ./task2.sh /path/to/output.txt"
    exit 1
fi

file=$1

# Provera da li fajl postoji
if [ ! -f "$file" ]; then
    echo "File $file doesn't exist"
    exit 1
fi

path=$(dirname "$file")
output_file="$path/output.json"

# Inicijalizacija JSON strukture
echo "{" > "$output_file"

# Parsiranje fajla i generisanje JSON-a
(cat "$file"; echo) | while read -r line; do
    if [[ $line =~ ^\[ ]]; then
        if [[ $line =~ \[([^\]]+)\],\ ([0-9]+)\.\.([0-9]+)\ tests ]]; then
            test_name="${BASH_REMATCH[1]}"
            test_name=$(echo "$test_name" | xargs) # remove spaces
            echo "  \"testName\": \"$test_name\"," >> "$output_file"
            echo "  \"tests\": [" >> "$output_file"
        else
            echo "Invalid test header format: $line" >&2
            exit 1
        fi
    elif [[ $line =~ ^(ok|not\ ok)\ *([0-9]+)\ *(.*?),\ *([0-9]+ms)$ ]]; then
        status=${BASH_REMATCH[1]}
        name=${BASH_REMATCH[3]}
        duration=${BASH_REMATCH[4]}
        status_bool=$( [[ $status == "ok" ]] && echo true || echo false )
        echo "    { \"name\": \"$name\", \"status\": $status_bool, \"duration\": \"$duration\" }," >> "$output_file"
    elif [[ $line =~ ([0-9]+)\ \(of\ ([0-9]+)\)\ tests\ passed,\ ([0-9]+)\ tests\ failed,\ rated\ as\ ([0-9.]+)%,\ spent\ ([0-9ms]+) ]]; then
        passed=${BASH_REMATCH[1]}
        failed=${BASH_REMATCH[3]}
        rating=${BASH_REMATCH[4]}
        duration=${BASH_REMATCH[5]}
        sed -i '$ s/,$//' "$output_file"  # Uklanja poslednji zarez
        echo "  ]," >> "$output_file"
        echo "  \"summary\": {" >> "$output_file"
        echo "    \"success\": $passed," >> "$output_file"
        echo "    \"failed\": $failed," >> "$output_file"
        echo "    \"rating\": $rating," >> "$output_file"
        echo "    \"duration\": \"$duration\"" >> "$output_file"
        echo "  }" >> "$output_file"
    fi
done >> "$output_file"

echo "}" >> "$output_file"

echo "JSON output written to $output_file"



