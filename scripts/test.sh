#!/bin/bash
set -e

# Test script for helmkit integration tests
# Usage: Called from Makefile with DEBUG, PWD environment variables

DEBUG="${DEBUG:-0}"
TEST_DIR="${PWD:-$(dirname "$(dirname "$(realpath "$0")")")}/tests"

# Function to run a test and report result
run_test() {
    local container_name="$1"
    local command="$2"

    local docker_args="docker run --rm \
        --user 1000:1000 \
        --tmpfs /tmp:size=100m \
        -v ${TEST_DIR}:/workspace/tests:ro \
        ${container_name} ${command}"

    if [ "$DEBUG" = "1" ]; then
        echo "🧪 Testing ${container_name}..."
        if eval $docker_args; then
            echo "✅ PASS"
        else
            echo "❌ FAIL"
            exit 1
        fi
    else
        echo -n "🧪 Testing ${container_name}... "
        if eval $docker_args > /dev/null 2>&1; then
            echo "✅ PASS"
        else
            echo "❌ FAIL"
            exit 1
        fi
    fi
}

# Run integration tests
run_test "helmkit-test" "/workspace/tests/integration/test-helmkit.sh"
run_test "helmkit-actions" "bash /workspace/tests/integration/test-helmkit.sh"
run_test "helmkit-actions" "bash /workspace/tests/integration/test-actions.sh"
