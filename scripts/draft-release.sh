#!/usr/bin/env bash

set -eou pipefail

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
XCFRAMEWORK_PATH=$2

REPO="mapbox/turf-swift"

echo "Creating a draft release on GitHub for SEM_VERSION: $SEM_VERSION..."
gh release create "$SEM_VERSION" \
    --repo "$REPO" \
    --title "$SEM_VERSION" \
    --notes "This is a draft release for $SEM_VERSION" \
    --draft

echo "Uploading XCFramework to the release..."

gh release upload "$SEM_VERSION" "$XCFRAMEWORK_PATH" --repo "$REPO"

echo "Draft release created, and assets uploaded!"