#!/usr/bin/env bash

set -eou pipefail

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
XCFRAMEWORK_PATH=$2
CHECKSUM_PATH=$3

REPO="mapbox/turf-swift"

echo "Creating a draft release on GitHub for SEM_VERSION: $SEM_VERSION..."
RELEASE_LINK=gh release create "$SEM_VERSION" \
    --repo "$REPO" \
    --title "$SEM_VERSION" \
    --notes "This is a draft release for $SEM_VERSION" \
    --draft

echo "Uploading artifacts to the release..."

gh release upload "$SEM_VERSION" "$XCFRAMEWORK_PATH" --repo "$REPO"
gh release upload "$SEM_VERSION" "$CHECKSUM_PATH" --repo "$REPO"

echo "Release link: $RELEASE_LINK"

# ZIP_LINK="$RELEASE_LINK/"
curl -L "$FILE_URL" -o "$DOWNLOADED_FILE"

echo "Draft release created, and assets uploaded!"