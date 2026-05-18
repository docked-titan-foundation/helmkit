#!/bin/bash

DOCKERFILE="Dockerfile"
README="README.md"

if [ -z "$1" ]; then
    RELEASE_VERSION=$(git tag --sort=-v:refname | head -1 | sed 's/^v//')
    if [ -z "$RELEASE_VERSION" ]; then
        echo "Error: Could not determine latest version from git tags"
        exit 1
    fi
else
    RELEASE_VERSION="$1"
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

if [[ "$RELEASE_VERSION" == *"beta"* ]]; then
    sed -i 's/ (latest beta)//' "$README" || true
    NEW_ROW="| $RELEASE_VERSION (latest beta) | $HELM_VERSION | $HELMFILE_VERSION | $KUBECTL_VERSION | $HELM_DIFF_VERSION | $HELM_SECRETS_VERSION | $SOPS_VERSION | $RELEASE_DATE|"
    awk -v row="$NEW_ROW" '
        /^### Beta Releases/ { found=1 }
        found && /^\|[-]+.*\|[-]+\|$/ {
            print; print row; found=0; next
        }
        { print }
    ' "$README" > "$README.tmp" && mv "$README.tmp" "$README" || true
else
    sed -i 's/ (latest)//' "$README" || true
    sed -i 's/ (latest beta)//' "$README" || true
    NEW_ROW="| $RELEASE_VERSION (latest) | $HELM_VERSION | $HELMFILE_VERSION | $KUBECTL_VERSION | $HELM_DIFF_VERSION | $HELM_SECRETS_VERSION | $SOPS_VERSION | $RELEASE_DATE|"
    awk -v row="$NEW_ROW" '
        /^### Stable Releases/ { found=1 }
        found && /^\|[-]+.*\|[-]+\|$/ {
            print; print row; found=0; next
        }
        { print }
    ' "$README" > "$README.tmp" && mv "$README.tmp" "$README" || true
fi

echo "Updated version matrix in README.md with version $RELEASE_VERSION"

sed -i "s|ghcr.io/docked-titan-foundation/helmkit/actions:[^ ]*\"|ghcr.io/docked-titan-foundation/helmkit/actions:v${RELEASE_VERSION}\"|g" action.yml || true

echo "Updated action.yml to use v$RELEASE_VERSION"
echo "Updating Makefile VERSION to v${RELEASE_VERSION}"
sed -i -E "s/^(VERSION[[:space:]]*:=[[:space:]]*).*/\1v${RELEASE_VERSION}/" Makefile || true

exit 0