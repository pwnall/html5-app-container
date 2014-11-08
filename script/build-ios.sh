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
cp app/config.xml tmp/ios/

# Build the app.
cd tmp/ios
../../node_modules/.bin/cordova build --platform android --debug
../../node_modules/.bin/cordova build --platform android --release
../../node_modules/.bin/cordova build --platform ios --debug --simulator || true
../../node_modules/.bin/cordova build --platform ios --release --device || true
cd ../..

# Sign the Android release app.
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore keys/android/release.keystore -storepass 'store-password' \
    -keypass 'key-password' \
    -signedjar \
    "tmp/ios/platforms/android/ant-build/CordovaApp-release-unaligned.apk" \
    "tmp/ios/platforms/android/ant-build/CordovaApp-release-unsigned.apk" \
    android_release
zipalign 4 \
    "tmp/ios/platforms/android/ant-build/CordovaApp-release-unaligned.apk" \
    "tmp/ios/platforms/android/ant-build/CordovaApp-release.apk"

# Bring the app up.
mkdir -p bin
cp "tmp/ios/platforms/android/ant-build/CordovaApp-debug.apk" \
    "bin/$APP_NAME-cordova-debug.apk"
cp "tmp/ios/platforms/android/ant-build/CordovaApp-release.apk" \
    "bin/$APP_NAME-cordova-release.apk" || true
rm -rf "bin/$APP_NAME.app"
cp -r "tmp/ios/platforms/ios/build/emulator/$APP_NAME.app" bin/ || true
rm -rf "bin/$APP_NAME-debug.app"
mv "bin/$APP_NAME.app" "bin/$APP_NAME-debug.app"
cp -r "tmp/ios/platforms/ios/build/device/$APP_NAME.app" bin/ || true
rm -rf "bin/$APP_NAME-release.app"
mv "bin/$APP_NAME.app" "bin/$APP_NAME-release.app" || true
