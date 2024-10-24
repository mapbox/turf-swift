#!/bin/bash

set -e

TAG=$1

if [ -z "$TAG" ]; then
    echo "Tag not provided!"
    exit 1
fi

REPO="mapbox/turf-swift"
XCFRAMEWORK_PATH="Turf.xcframework.zip"
RELEASE_NAME="$TAG"

echo "Running xcframework.sh..."
"$(pwd)/scripts/xcframework.sh"

echo "Creating a draft release on GitHub for tag: $TAG..."
gh release create "$TAG" \
  --repo "$REPO" \
  --title "$RELEASE_NAME" \
  --notes "This is a draft release for $TAG" \
  --draft

echo "Uploading XCFramework to the release..."
gh release upload "$TAG" "$XCFRAMEWORK_PATH" \
  --repo "$REPO"

echo "Draft release created, and assets uploaded!"
