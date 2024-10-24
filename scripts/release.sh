#!/usr/bin/env bash

set -eou pipefail

RELEASE_TAG="v3.2.19"
ARTIFACT_NAME="Turf.xcframework.zip"
PACKAGE_FILE="Package.swift"

echo "Fetching draft release with tag: $RELEASE_TAG"
RELEASE_ID=$(gh release view "$RELEASE_TAG" --repo "$REPO" --json id -q '.id')

if [[ -z "$RELEASE_ID" ]]; then
    echo "Release with tag $RELEASE_TAG not found."
    exit 1
fi

echo "Downloading artifact: $ARTIFACT_NAME"
gh release download "$RELEASE_TAG" --repo "$REPO" --pattern "$ARTIFACT_NAME" --dir .

CHECKSUM=$(swift package compute-checksum "$ARTIFACT_NAME")
EXPECTED_CHECKSUM=$(grep -Eo 'checksum: "[a-f0-9]+"' "$PACKAGE_FILE" | awk -F'"' '{print $2}')

echo "Computed checksum: $CHECKSUM"
echo "Expected checksum: $EXPECTED_CHECKSUM"

if [ "$CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
    echo "Checksums do not match."
    exit 1
fi

echo "Checksums match."