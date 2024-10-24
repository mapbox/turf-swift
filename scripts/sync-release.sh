#!/usr/bin/env bash

set -eou pipefail

git config --global user.name "MapboxCI"
git config --global user.email "no-reply@mapbox.com"

git fetch origin
git switch release
git pull origin release


CHECKSUM=$(<xcframework_checksum.txt)
echo "Checksum: $CHECKSUM"
git checkout -b "update-turf-checksum-$CHECKSUM"

git merge origin/main --no-ff || (echo "Merge conflict occurred, failing the job." && exit 1)

echo "Updating Swift Package manifest (Package.swift) with checksum…"
sed -i '' -E "s/checksum: \"[^\"]+\"/checksum: \"${CHECKSUM}\"/" Package.swift

if git diff --exit-code > /dev/null; then
  echo "No changes detected after updating checksum. Exiting without creating a PR."
  exit 0
fi

git add Package.swift
git commit -m "Update checksum for Turf.xcframework.zip [skip ci]"

gh pr create --base release --head update-turf-checksum --title "Update checksum for Turf.xcframework.zip" --body "This PR updates the checksum for Turf.xcframework.zip"
