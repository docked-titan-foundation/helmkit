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
            ((PASS++))
        else
            echo "❌ FAIL (expected failure but passed)"
            ((FAIL++))
        fi
    else
        if [ "$expected" -ne 0 ]; then
            echo "✅ PASS (expected failure)"
            ((PASS++))
        else
            echo "❌ FAIL"
            cat /tmp/test_output
            ((FAIL++))
        fi
    fi
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Helmkit Integration Test Suite"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# --- Binary presence tests ---
echo ""
echo "📦 Binary Verification"
run_test "helm binary exists"     "command -v helm"
run_test "helmfile binary exists" "command -v helmfile"
run_test "kubectl binary exists"  "command -v kubectl"
run_test "sops binary exists"     "command -v sops"

# --- Version output tests ---
echo ""
echo "🔢 Version Validation"
run_test "helm version output"     "helm version --short | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+'"
run_test "helmfile version output" "helmfile --version | grep -E '[0-9]+\.[0-9]+\.[0-9]+'"
run_test "kubectl version output"  "kubectl version --client | grep -E 'v[0-9]+'"
run_test "sops version output"     "sops --version | grep -E '[0-9]+\.[0-9]+\.[0-9]+'"

# --- Plugin tests ---
echo ""
echo "🔌 Plugin Verification"
run_test "helm-diff plugin installed"    "helm plugin list | grep diff"
run_test "helm-secrets plugin installed" "helm plugin list | grep secrets"

# --- Security tests ---
echo ""
echo "🔒 Security Validation"
run_test "not running as root" \
    "[ \"\$(id -u)\" != '0' ]"
run_test "no setuid binaries in /usr/local/bin" \
    "! find /usr/local/bin -perm /4000 | grep -q ."
run_test "helm binary is not world-writable" \
    "! test -w /usr/local/bin/helm"

# --- Functional tests ---
echo ""
echo "⚙️  Functional Tests"
run_test "helm create basic chart" \
    "helm create /tmp/test-chart && ls /tmp/test-chart/Chart.yaml"
run_test "helm lint created chart" \
    "helm lint /tmp/test-chart"
run_test "helm template renders successfully" \
    "helm template test-release /tmp/test-chart | grep -q 'kind: ServiceAccount'"
run_test "helmfile init succeeds" \
    "helmfile init --force"

# --- Summary ---
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: ✅ $PASS passed | ❌ $FAIL failed | ⏭️  $SKIP skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$FAIL" -eq 0 ] || exit 1
