#!/bin/sh
# entrypoint.sh

TOOL=$1
ARGS=$2

# Run the tool and capture output
OUTPUT=$($TOOL $ARGS 2>&1)
EXIT_CODE=$?

# Write outputs to GITHUB_OUTPUT
echo "exit-code=${EXIT_CODE}" >> $GITHUB_OUTPUT
echo "output=${OUTPUT}" >> $GITHUB_OUTPUT

exit $EXIT_CODE
