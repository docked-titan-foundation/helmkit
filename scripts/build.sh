#!/bin/bash
set -e

# Build script for helmkit images
# Usage: Called from Makefile with DEBUG, IMAGE_NAME, VERSION environment variables

DEBUG="${DEBUG:-0}"
IMAGE_NAME="${IMAGE_NAME:-helmkit}"
VERSION="${VERSION:-local/0.0.0}"

# Function to build an image and report result
build_image() {
    local target="$1"
    local image_tag="$2"
    local build_args="--target $target \
        --build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
        --build-arg VCS_REF=$(git rev-parse --short HEAD) \
        --build-arg APP_VERSION=$VERSION \
        -t $image_tag ."

    if [ "$DEBUG" = "1" ]; then
        echo "📦 Building $image_tag..."
        if docker build $build_args; then
            echo "✅ PASS"
        else
            echo "❌ FAIL"
            exit 1
        fi
    else
        echo -n "📦 Building $image_tag... "
        if docker build $build_args > /dev/null 2>&1; then
            echo "✅ PASS"
        else
            echo "❌ FAIL"
            exit 1
        fi
    fi
}

# Build helmkit-test image
build_image "runtime" "${IMAGE_NAME}-test:${VERSION}"

# Build helmkit-actions image
build_image "actions" "${IMAGE_NAME}-actions:${VERSION}"
