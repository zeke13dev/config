#!/bin/bash

# Define output file
output_file="all_in_one.lua"

# Start with init.lua
cat init.lua > "$output_file"

# Append all .lua files in lua/ directory (you may want to adjust the order if needed)
find lua/ -type f -name "*.lua" | sort | while read -r file; do
    echo -e "\n-- File: $file --\n" >> "$output_file"  # Add a comment for each file
    cat "$file" >> "$output_file"
done

echo "All files have been merged into $output_file"

