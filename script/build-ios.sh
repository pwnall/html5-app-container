#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh


# Copy files into app.
rm -f tmp/ios/www/master.css
rm -f tmp/ios/www/main.js
rm -rf tmp/ios/www/css
rm -rf tmp/ios/www/img
rm -rf tmp/ios/www/js
cp -r app/* tmp/ios/www/

# Build the app.
cd tmp/ios
../../node_modules/.bin/cordova build --release --device

# Bring the app up.
cd ../..
mkdir -p bin
cp -r "tmp/ios/platforms/ios/build/device/$APP_NAME.app" bin/
