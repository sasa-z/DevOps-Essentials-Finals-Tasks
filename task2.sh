#!/bin/bash

#check if argument provided

if [ $# -lt 1 ]; then
    echo "Usage: ./task2.sh /path/to/output.txt"
    exit 0
fi

file=$1

#chedk if file exists
if [ ! -f $file ]; then
    echo "File $file doesn't exit"
    exit 1
fi

#extract directory from file
path=$(dirname "$file")

#variables initialization
tests_started=0
test_entries=()
test_name=""
first_test_id=0
last_test_id=0
test_cases_name=""

#parsing and JSON generation

(cat "$file"; echo;) | while read -r line; do





