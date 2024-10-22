#!/usr/bin/env bash

set -eou pipefail

CHECKSUM=$(swift package compute-checksum MapboxCommon.zip)

echo "$CHECKSUM" > checksum.txt

git config --global user.name "CI Bot"
git config --global user.email "ci-bot@example.com"

git add checksum.txt

git commit -m "Add checksum for Turf.xcframework.zip [skip ci]"

git push origin "$(git rev-parse --abbrev-ref HEAD)"
