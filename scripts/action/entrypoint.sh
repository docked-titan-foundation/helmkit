#!/bin/sh
# entrypoint.sh

# Set default GITHUB_OUTPUT if not set or empty
if [ -z "$GITHUB_OUTPUT" ]; then
    GITHUB_OUTPUT="/workspace/github_output.txt"
    # Ensure the directory exists
    mkdir -p "$(dirname "$GITHUB_OUTPUT")"
fi

TOOL=$1
ARGS=$2

# Run the tool and capture output
OUTPUT=$($TOOL $ARGS 2>&1)
EXIT_CODE=$?

# Write outputs to GITHUB_OUTPUT
echo "exit-code=${EXIT_CODE}" >> "$GITHUB_OUTPUT"
echo "output=${OUTPUT}" >> "$GITHUB_OUTPUT"

exit $EXIT_CODE
