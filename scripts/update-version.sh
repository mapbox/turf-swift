#!/usr/bin/env bash

set -eou pipefail

function step { >&2 echo -e "\033[1m\033[36m* $@\033[0m"; }
function finish { >&2 echo -en "\033[0m"; }
trap finish EXIT

# Read semantic version from version.txt
if [ ! -f version.txt ]; then
    echo "version.txt file not found."
    exit 1
fi

SEM_VERSION=$(<version.txt)
SEM_VERSION=${SEM_VERSION/#v}
SHORT_VERSION=${SEM_VERSION%-*}
MINOR_VERSION=${SEM_VERSION%.*}
YEAR=$(date '+%Y')

step "Version ${SEM_VERSION}"

# Output the checksum
echo "Retrieved XCFramework checksum: $CHECKSUM"

step "Updating Xcode targets to version ${SHORT_VERSION}…"

xcrun agvtool bump -all
xcrun agvtool new-marketing-version "${SHORT_VERSION}"

step "Updating CocoaPods podspecs to version ${SEM_VERSION}…"

find . -type f -name '*.podspec' -exec sed -i '' "s/^ *s.version *=.*$/  s.version = \"${SEM_VERSION}\"/" {} +

# Update the Swift Package manifest with the new version and checksum
step "Updating Swift Package manifest (Package.swift) with version ${SEM_VERSION} and checksum…"

sed -i '' -E "s|url: \"https://github.com/mapbox/turf-swift/releases/download/v[^\"]+|url: \"https://github.com/mapbox/turf-swift/releases/download/v${SEM_VERSION}|" Package.swift
sed -i '' -E "s/checksum: \"[^\"]+\"/checksum: \"${CHECKSUM}\"/" Package.swift

# Skip updating the installation instructions for patch releases or prereleases.
if [[ $SHORT_VERSION == $SEM_VERSION && $SHORT_VERSION == *.0 ]]; then
    step "Updating readmes to version ${SEM_VERSION}…"
    sed -i '' -E "s/~> *[^']+/~> ${MINOR_VERSION}/g; s/.git\", from: \"*[^\"]+/.git\", from: \"${SEM_VERSION}/g" README.md
elif [[ $SHORT_VERSION != $SEM_VERSION ]]; then
    step "Updating readmes to version ${SEM_VERSION}…"
    sed -i '' -E "s/:tag => 'v[^']+'/:tag => 'v${SEM_VERSION}'/g; s/\"mapbox\/turf-swift\" \"v[^\"]+\"/\"mapbox\/turf-swift\" \"v${SEM_VERSION}\"/g; s/\.exact\(\"*[^\"]+/.exact(\"${SEM_VERSION}/g" README.md
fi

# Skip updating the documentation badge for prereleases.
if [[ $SHORT_VERSION == $SEM_VERSION ]]; then
    step "Updating readmes to version ${SEM_VERSION}…"
    sed -i '' -E "s/turf-swift\/[^/]+\/badge\.svg/turf-swift\/${SEM_VERSION}\/badge.svg/g" README.md
fi

step "Updating copyright year to ${YEAR}…"

sed -i '' -E "s/© ([0-9]{4})[–-][0-9]{4}/© \\1–${YEAR}/g" LICENSE.md docs/jazzy.yml
