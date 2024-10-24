#!/usr/bin/env bash

set -eou pipefail

BUILD_DIRECTORY=${1:-"."}
echo "Temporary directory: $BUILD_DIRECTORY"

platforms=("iOS" "iOS Simulator" "macOS" "macOS,variant=Mac Catalyst" "tvOS" "tvOS Simulator" "watchOS" "watchOS Simulator" "visionOS" "visionOS Simulator")

# build Turf for each platform

commands=()
for platform in "${platforms[@]}"
do
  xcodebuild archive \
    -scheme "Turf" \
    -archivePath "$BUILD_DIRECTORY/archives/Turf-$platform.xcarchive" \
    -destination "generic/platform=$platform" \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SUPPORTS_MACCATALYST=YES

  commands+=("-archive" "$BUILD_DIRECTORY/archives/Turf-$platform.xcarchive")
  commands+=("-framework" "Turf.framework")

done

xcodebuild -create-xcframework "${commands[@]}" -output "$BUILD_DIRECTORY/Turf.xcframework"
codesign --timestamp -v --sign "Apple Distribution: Mapbox, Inc." "$BUILD_DIRECTORY/Turf.xcframework"

ZIP_OUTPUT_PATH="$BUILD_DIRECTORY/Turf.xcframework.zip"
rm -rf "$ZIP_OUTPUT_PATH"
ditto -c -k --sequesterRsrc --keepParent "$BUILD_DIRECTORY/Turf.xcframework" "$ZIP_OUTPUT_PATH"

CHECKSUM=$(swift package compute-checksum "$ZIP_OUTPUT_PATH")
echo "$CHECKSUM" > "$BUILD_DIRECTORY/xcframework_checksum.txt"
echo "Checksum: $CHECKSUM"
