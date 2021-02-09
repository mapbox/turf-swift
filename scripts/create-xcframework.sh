#!/bin/bash

TURF_BUILD_DIR="Build"
TURF_IOS_SIMULATOR_XCARCHIVE="$TURF_BUILD_DIR/iOS Simulator.xcarchive"
TURF_IOS_XCARCHIVE="$TURF_BUILD_DIR/iOS.xcarchive"
TURF_MAC_CATALYST_XCARCHIVE="$TURF_BUILD_DIR/Mac Catalyst.xcarchive"
TURF_MACOS_XCARCHIVE="$TURF_BUILD_DIR/macOS.xcarchive"
TURF_FRAMEWORK_PATH="Products/Library/Frameworks/Turf.framework"

rm -rf "$TURF_BUILD_DIR"
mkdir "$TURF_BUILD_DIR"

xcodebuild archive \
  -scheme "Turf iOS" \
  -configuration Release \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$TURF_IOS_SIMULATOR_XCARCHIVE"

xcodebuild archive \
  -scheme "Turf iOS" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$TURF_IOS_XCARCHIVE"

xcodebuild archive \
  -scheme "Turf iOS" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$TURF_MAC_CATALYST_XCARCHIVE"

xcodebuild archive \
  -scheme "Turf Mac" \
  -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$TURF_MACOS_XCARCHIVE"

xcodebuild archive \
  -create-xcframework \
  -framework "$TURF_IOS_SIMULATOR_XCARCHIVE/$TURF_FRAMEWORK_PATH" \
  -framework "$TURF_IOS_XCARCHIVE/$TURF_FRAMEWORK_PATH" \
  -framework "$TURF_MAC_CATALYST_XCARCHIVE/$TURF_FRAMEWORK_PATH" \
  -framework "$TURF_MACOS_XCARCHIVE/$TURF_FRAMEWORK_PATH" \
  -output "$TURF_BUILD_DIR/Turf.xcframework"

pushd "$TURF_BUILD_DIR"
zip -r "Turf.xcframework.zip" "Turf.xcframework"
popd

swift package compute-checksum "$TURF_BUILD_DIR/Turf.xcframework.zip" > "$TURF_BUILD_DIR/Turf.xcframework.zip.checksum"
