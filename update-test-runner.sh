#!/bin/bash
set -e

# Variables
GIST_ID="https://gist.github.com/parasharrajat/9f3654c4688e6038a0e5dd25175c583e" # Replace with your Gist ID
DIFF_FILENAME="Main.diff"
TEMP_DIFF_FILE="main.diff"

# Generate the diff file
git diff main..test-runner > "$TEMP_DIFF_FILE"

# Check if the diff file is empty
if [ ! -s "$TEMP_DIFF_FILE" ]; then
    echo "::error::No changes detected between test-runner and main branches."
    exit 1
fi

# Update the Gist using gh CLI
gh gist edit "$GIST_ID" --filename "$DIFF_FILENAME" "$TEMP_DIFF_FILE"

# Clean up
rm "$TEMP_DIFF_FILE"

echo "Gist updated successfully with the latest diff."
