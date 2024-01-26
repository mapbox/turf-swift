#!/usr/bin/env bash

set -e
set -o pipefail
set -u

if [ -z `which jazzy` ]; then
    echo "Installing jazzy…"
    gem install jazzy
    if [ -z `which jazzy` ]; then
        echo "Unable to install jazzy."
        exit 1
    fi
fi


OUTPUT=${OUTPUT:-documentation}

BRANCH=$( git describe --tags --match=v*.*.* --abbrev=0 )
SHORT_VERSION=$( echo ${BRANCH} | sed 's/^v//' )
RELEASE_VERSION=$( echo ${SHORT_VERSION} | sed -e 's/-.*//' )
MINOR_VERSION=$( echo ${SHORT_VERSION} | grep -Eo '^\d+\.\d+' )

rm -rf ${OUTPUT}
mkdir -p ${OUTPUT}

#cp -r docs/img "${OUTPUT}"

jazzy \
    --config docs/jazzy.yml \
    --sdk macosx \
    --module-version ${SHORT_VERSION} \
    --github-file-prefix "https://github.com/mapbox/turf-swift/tree/${BRANCH}" \
    --readme README.md \
    --root-url "https://mapbox.github.io/turf-swift/${RELEASE_VERSION}/" \
    --output ${OUTPUT} \
    --build-tool-arguments CODE_SIGN_IDENTITY=,CODE_SIGNING_REQUIRED=NO,CODE_SIGNING_ALLOWED=NO

echo $SHORT_VERSION > $OUTPUT/latest_version
