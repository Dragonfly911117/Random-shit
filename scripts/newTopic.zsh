#!/bin/zsh

# Check if parameters are provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: ./script_name <Topic> <filename>"
  exit 1
fi

# Variables
Topic=$1
filename=$2

# File paths
readme_path="../README.md"
doc_path="../docs/${filename}.md"

# Step 1: Append to second-to-last line in ../README.md
# Remove the last blank line, append the new content, then add the blank line back
sed -i  '$d' $readme_path
echo "- [${Topic}](docs/${filename}.md)" >> $readme_path
echo "" >> $readme_path  # Re-add blank line at EOF

# Step 2: Create ../docs/${filename}.md
touch $doc_path

echo "Added entry to README and created docs/${filename}.md"

