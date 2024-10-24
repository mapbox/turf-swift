#!/usr/bin/env bash

set -eou pipefail

if [ $# -eq 0 ]; then
    echo "Usage: v<semantic version>"
    exit 1
fi

SEM_VERSION=$1
CHECKSUM=""

function checkout {
    git config --global color.ui false
    git config --global user.name "MapboxCI"
    git config --global user.email "no-reply@mapbox.com"
    git checkout -B "update-versions-$SEM_VERSION"
}

function update_versions {
    SEM_VERSION=${SEM_VERSION/#v}
    SHORT_VERSION=${SEM_VERSION%-*}
    MINOR_VERSION=${SEM_VERSION%.*}
    YEAR=$(date '+%Y')

    echo "Version ${SEM_VERSION}"
    echo "Updating Xcode targets to version ${SHORT_VERSION}…"

    xcrun agvtool bump -all
    xcrun agvtool new-marketing-version "${SHORT_VERSION}"

    echo "Updating CocoaPods podspecs to version ${SEM_VERSION}…"

    find . -type f -name '*.podspec' -exec sed -i '' "s/^ *s.version *=.*$/  s.version = \"${SEM_VERSION}\"/" {} +

    if [[ $SHORT_VERSION == "$SEM_VERSION" && $SHORT_VERSION == "*.0" ]]; then
        echo "Updating readmes to version ${SEM_VERSION}…"
        sed -i '' -E "s/~> *[^']+/~> ${MINOR_VERSION}/g; s/.git\", from: \"*[^\"]+/.git\", from: \"${SEM_VERSION}/g" README.md
    elif [[ $SHORT_VERSION != "$SEM_VERSION" ]]; then
        echo "Updating readmes to version ${SEM_VERSION}…"
        sed -i '' -E "s/:tag => 'v[^']+'/:tag => 'v${SEM_VERSION}'/g; s/\"mapbox\/turf-swift\" \"v[^\"]+\"/\"mapbox\/turf-swift\" \"v${SEM_VERSION}\"/g; s/\.exact\(\"*[^\"]+/.exact(\"${SEM_VERSION}/g" README.md
    fi

    # Skip updating the documentation badge for prereleases.
    if [[ $SHORT_VERSION == $SEM_VERSION ]]; then
        echo "Updating readmes to version ${SEM_VERSION}…"
        sed -i '' -E "s/turf-swift\/[^/]+\/badge\.svg/turf-swift\/${SEM_VERSION}\/badge.svg/g" README.md
    fi

    echo "Updating copyright year to ${YEAR}…"

    sed -i '' -E "s/© ([0-9]{4})[–-][0-9]{4}/© \\1–${YEAR}/g" LICENSE.md docs/jazzy.yml
}

function update_swift_package {
    sh scripts/xcframework.sh .
    CHECKSUM=$(<xcframework_checksum.txt)
    echo "Retrieved XCFramework checksum: $CHECKSUM"

    echo "Updating Swift Package manifest (Package.swift) with version ${SEM_VERSION} and checksum…"
    sed -i '' -E "s|url: \"https://github.com/mapbox/turf-swift/releases/download/v[^\"]+|url: \"https://github.com/mapbox/turf-swift/releases/download/v${SEM_VERSION}/Turf.xcframework.zip|" Package.swift
    sed -i '' -E "s/checksum: \"[^\"]+\"/checksum: \"${CHECKSUM}\"/" Package.swift
}

function commit {
    if git diff --quiet; then
        echo "No changes detected, skipping push."
        exit 0
    fi

    git diff
    git add .

    echo "Commit changed"
    git commit -m "Update versions for Turf.xcframework"

    echo "Pushing to upstream"
    git push --set-upstream origin "update-versions-$SEM_VERSION"
}

checkout
update_versions
update_swift_package
commit

echo "Create PR"
# gh pr create --base main --head "update-versions-$SEM_VERSION" --title "Update version for Turf" --body "This PR updates versions for Turf"
