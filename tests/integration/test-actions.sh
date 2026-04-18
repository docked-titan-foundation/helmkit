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

# --- Binary presence tests ---
echo ""
echo "📦 Binary Verification"
run_test "helm binary exists"     "command -v helm"
run_test "helmfile binary exists" "command -v helmfile"

# --- Helm version test ---
echo ""
echo "🔢 Helm Version Validation"
run_test "helm version output" \
    "helm version --short | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+'"

# --- Helmfile version test ---
echo ""
echo "🔢 Helmfile Version Validation"
run_test "helmfile version output" \
    "helmfile --version | grep -E '[0-9]+\.[0-9]+\.[0-9]+'"

# --- Helm lint test ---
echo ""
echo "📋 Helm Lint Tests"
run_test "helm lint test-chart" \
    "helm lint tests/test-chart/"
run_test "helm template test-chart" \
    "helm template test-release tests/test-chart/ | grep -q 'kind: ConfigMap'"

# --- Helmfile lint test ---
echo ""
echo "📋 Helmfile Lint Tests"
run_test "helmfile lint test-helmfile" \
    "helmfile -f tests/helmfile.yaml lint"

# --- Security tests ---
echo ""
echo "🔒 Security Validation"
run_test "not running as root" \
    "[ \"\$(id -u)\" != '0' ]"
run_test "no setuid binaries in /usr/local/bin" \
    "! find /usr/local/bin -perm /4000 | grep -q ."

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed | ❌ $FAIL failed | ⏭️  $SKIP skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] || exit 1