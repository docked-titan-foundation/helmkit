#!/bin/sh
# entrypoint.sh

tool="$1"
shift

# If there is exactly one remaining arg, treat it as a string to split.
# GitHub Actions passes inputs.args as a single string when it contains spaces.
if [ $# -eq 1 ]; then
    # shellcheck disable=SC2086
    exec sh -c '"$1" $2' -- "$tool" "$1"
else
    exec "$tool" "$@"
fi
