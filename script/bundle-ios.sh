#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh

# Create the bundle directory.
mkdir -p bin/js_bundles

# Copy the JS into the bundle.
cat tmp/ios/platforms/ios/platform_www/cordova.js \
    tmp/ios/plugins/org.chromium.*/*.js \
    tmp/ios/plugins/org.chromium.*/*/*.js \
    tmp/ios/plugins/org.chromium.*/*/*/*.js \
    tmp/ios/plugins/org.apache.cordova.*/www/*.js \
    tmp/ios/plugins/org.apache.cordova.*/www/ios/*.js \
    > bin/js_bundles/ios.js
