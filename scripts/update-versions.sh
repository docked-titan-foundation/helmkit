#!/bin/bash

RELEASE_VERSION="$1"
DOCKERFILE="Dockerfile"
README="README.md"

if [ -z "$RELEASE_VERSION" ]; then
    echo "Usage: $0 <release-version>"
    exit 1
fi

if [ ! -f "$DOCKERFILE" ]; then
    echo "Error: Dockerfile not found"
    exit 1
fi

if [ ! -f "$README" ]; then
    echo "Error: README.md not found"
    exit 1
fi

HELM_VERSION=$(grep -m1 'ARG HELM_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true
HELMFILE_VERSION=$(grep -m1 'ARG HELMFILE_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true
KUBECTL_VERSION=$(grep -m1 'ARG KUBECTL_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true
HELM_DIFF_VERSION=$(grep -m1 'ARG HELM_DIFF_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true
SOPS_VERSION=$(grep -m1 'ARG SOPS_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true
HELM_SECRETS_VERSION=$(grep -m1 'ARG HELM_SECRETS_VERSION=' "$DOCKERFILE" | sed 's/.*=\([^ ]*\).*/\1/') || true

RELEASE_DATE=$(date +%Y-%m-%d)

sed -i 's/ (latest)//' "$README" || true

NEW_ROW="| $RELEASE_VERSION (latest) | $HELM_VERSION | $HELMFILE_VERSION | $KUBECTL_VERSION | $HELM_DIFF_VERSION | $HELM_SECRETS_VERSION | $SOPS_VERSION | $RELEASE_DATE|"

sed -i "/^|-----------------|/a\\
$NEW_ROW" "$README" || true

echo "Updated version matrix in README.md with version $RELEASE_VERSION"

sed -i "s|ghcr.io/docked-titan-foundation/helmkit/actions:[^ ]*\"|ghcr.io/docked-titan-foundation/helmkit/actions:v${RELEASE_VERSION}\"|g" action.yml || true

echo "Updated action.yml to use v$RELEASE_VERSION"

exit 0