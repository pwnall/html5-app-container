#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh

# Create the bundle directory.
mkdir -p bin/js_bundles

# Copy the JS into the bundle.
cat tmp/android/assets/www/cordova.js \
    tmp/android/assets/www/cordova_plugins.js \
    tmp/android/assets/www/plugins/org.chromium.*/*.js \
    tmp/android/assets/www/plugins/org.chromium.*/*/*.js \
    tmp/android/assets/www/plugins/org.chromium.*/*/*/*.js \
    tmp/android/assets/www/plugins/org.apache.cordova.*/www/*.js \
    tmp/android/assets/www/plugins/org.apache.cordova.*/www/android/*.js \
    > bin/js_bundles/android.js
