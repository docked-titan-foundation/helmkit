#!/usr/bin/env bash

set -euo pipefail

PASS=0
FAIL=0
SKIP=0

run_test() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-0}"

    echo -n "  Testing: $name ... "
    if eval "$cmd" > /tmp/test_output 2>&1; then
        if [ "$expected" -eq 0 ]; then
            echo "✅ PASS"
            PASS=$((PASS + 1))
        else
            echo "❌ FAIL (expected failure but passed)"
            FAIL=$((FAIL + 1))
        fi
    else
        if [ "$expected" -ne 0 ]; then
            echo "✅ PASS (expected failure)"
            PASS=$((PASS + 1))
        else
            echo "❌ FAIL"
            cat /tmp/test_output
            FAIL=$((FAIL + 1))
        fi
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Helmkit Actions Integration Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📦 Building Actions Docker Image"
if docker build -t helmkit-actions -f Dockerfile.action .; then
    echo "✅ PASS - Built helmkit-actions image"
    PASS=$((PASS + 1))
else
    echo "❌ FAIL - Failed to build helmkit-actions image"
    FAIL=$((FAIL + 1))
    exit 1
fi

# --- Helm version test ---
echo ""
echo "🔢 Helm Version Validation"
run_test "helm version output" \
    "docker run --rm --entrypoint helm helmkit-actions version --short | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+'"

# --- Helmfile version test ---
echo ""
echo "🔢 Helmfile Version Validation"
run_test "helmfile version output" \
    "docker run --rm --entrypoint helmfile helmkit-actions --version | grep -E '[0-9]+\.[0-9]+\.[0-9]+'"

# --- Helm lint test ---
echo ""
echo "📋 Helm Lint Tests"
run_test "helm lint test-chart" \
    "docker run --rm -v $PWD:/workspace --entrypoint helm helmkit-actions lint tests/test-chart/"
run_test "helm template test-chart" \
    "docker run --rm -v $PWD:/workspace --entrypoint helm helmkit-actions template test-release tests/test-chart/ | grep -q 'kind: ConfigMap'"

# --- Helmfile lint test ---
echo ""
echo "📋 Helmfile Lint Tests"
run_test "helmfile lint test-helmfile" \
    "docker run --rm -v $PWD:/workspace --entrypoint helmfile helmkit-actions -f tests/helmfile.yaml lint"

# --- Security tests (running as root) ---
echo ""
echo "🔒 Security Validation"
run_test "running as root (uid 0)" \
    "docker run --rm --entrypoint id helmkit-actions -u | grep -q '^0$'"

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed | ❌ $FAIL failed | ⏭️  $SKIP skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] || exit 1