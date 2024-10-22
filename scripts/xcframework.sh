#!/usr/bin/env bash

set -eou pipefail

ZIP_OUTPUT_PATH=${1:-$(pwd)/Turf.xcframework.zip}

TEMPORARY_DIRECTORY=$(mktemp -d)
echo "Temporary directory: $TEMPORARY_DIRECTORY"

platforms=("iOS" "iOS Simulator" "macOS" "macOS,variant=Mac Catalyst" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator" "visionOS" "visionOS Simulator")

# build Turf for each platform

commands=()
for platform in "${platforms[@]}"
do
  xcodebuild archive \
    -scheme "Turf" \
    -archivePath "$TEMPORARY_DIRECTORY/archives/Turf-$platform.xcarchive" \
    -destination "generic/platform=$platform" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SUPPORTS_MACCATALYST=YES

  commands+=("-archive" "$TEMPORARY_DIRECTORY/archives/Turf-$platform.xcarchive")
  commands+=("-framework" "Turf.framework")

done

xcodebuild -create-xcframework "${commands[@]}" -output "$TEMPORARY_DIRECTORY/Turf.xcframework"
codesign --timestamp -v --sign "Apple Distribution: Mapbox, Inc." "$TEMPORARY_DIRECTORY/Turf.xcframework"

ZIP_OUTPUT_PATH=$(pwd)/Turf.xcframework.zip
rm -rf "$ZIP_OUTPUT_PATH"

ditto -c -k --sequesterRsrc --keepParent "$TEMPORARY_DIRECTORY/Turf.xcframework" "$ZIP_OUTPUT_PATH"
