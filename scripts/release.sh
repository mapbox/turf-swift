#!/usr/bin/env bash

set -eou pipefail

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

RELEASE_TAG=$1
ARTIFACT_NAME="Turf.xcframework.zip"
REPO="mapbox/turf-swift"

function setup_token {
    GH_TOKEN=$(mbx-ci github writer public token)
    export GH_TOKEN

    git config user.email "release-bot@mapbox.com"
    git config user.name "Release SDK bot"
}

function validate_release_artifact_checksum {
    echo "Fetching draft release with tag: $RELEASE_TAG"
    RELEASE_ID=$(gh release view "$RELEASE_TAG" --repo "$REPO" --json id -q '.id')

    if [[ -z "$RELEASE_ID" ]]; then
        echo "Release with tag $RELEASE_TAG not found."
        exit 1
    fi

    echo "Downloading artifact: $ARTIFACT_NAME"
    gh release download "$RELEASE_TAG" --repo "$REPO" --pattern "$ARTIFACT_NAME" --dir .

    CHECKSUM=$(swift package compute-checksum "$ARTIFACT_NAME")
    EXPECTED_CHECKSUM=$(grep -Eo 'checksum: "[a-f0-9]+"' "Package.swift" | awk -F'"' '{print $2}')

    echo "Computed checksum: $CHECKSUM"
    echo "Expected checksum: $EXPECTED_CHECKSUM"

    if [ "$CHECKSUM" != "$EXPECTED_CHECKSUM" ]; then
        echo "Checksums do not match."
        exit 1
    fi

    echo "Checksums match."
}

function publish_github_release {
    echo "Publishing release $RELEASE_TAG..."
    gh release edit "$RELEASE_TAG" --repo "$REPO" --draft=false --prerelease=true
    echo "Release $RELEASE_TAG is now published."
}

function validate_manifests {
    git fetch --tags
    git checkout "tags/$RELEASE_TAG"

    echo "Resolve Swift package dependencies"
    swift package resolve

    echo "Lint CocoaPods podspec"
    pod spec lint
}

function publish_cocoapods_release {
    echo "Push CocoaPods podspec"
    pod trunk push
}

setup_token
validate_release_artifact_checksum
publish_github_release
validate_manifests
# publish_cocoapods_release
