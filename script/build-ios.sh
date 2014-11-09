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

# Bundle Cordova's platform files -- iOS.
# NOTE: the iOS build clears its www folder, but it copies the contents of
#       platform_www in it, so we can stash our code there
cat tmp/ios/platforms/ios/www/cordova.js \
    tmp/ios/platforms/ios/www/cordova_plugins.js \
    tmp/ios/platforms/ios/www/plugins/org.chromium.*/*.js \
    tmp/ios/platforms/ios/www/plugins/org.chromium.*/*/*.js \
    tmp/ios/platforms/ios/www/plugins/org.chromium.*/*/*/*.js \
    tmp/ios/platforms/ios/www/plugins/org.apache.cordova.*/www/*.js \
    tmp/ios/platforms/ios/www/plugins/org.apache.cordova.*/www/ios/*.js \
    > tmp/ios/platforms/ios/platform_www/cordova_all.xl.js
node_modules/.bin/uglifyjs --screw-ie8 -c -m \
    -o tmp/ios/platforms/ios/platform_www/cordova_all.min.js \
    tmp/ios/platforms/ios/platform_www/cordova_all.xl.js
rm tmp/ios/platforms/ios/platform_www/cordova_all.xl.js

# Bundle Cordova's platform files -- Android.
cat tmp/ios/platforms/android/assets/www/cordova.js \
    tmp/ios/platforms/android/assets/www/cordova_plugins.js \
    tmp/ios/platforms/android/assets/www/plugins/org.chromium.*/*.js \
    tmp/ios/platforms/android/assets/www/plugins/org.chromium.*/*/*.js \
    tmp/ios/platforms/android/assets/www/plugins/org.chromium.*/*/*/*.js \
    tmp/ios/platforms/android/assets/www/plugins/org.apache.cordova.*/www/*.js \
    tmp/ios/platforms/android/assets/www/plugins/org.apache.cordova.*/www/android/*.js \
    > tmp/ios/platforms/android/assets/www/cordova_all.xl.js
node_modules/.bin/uglifyjs --screw-ie8 -c -m \
    -o tmp/ios/platforms/android/assets/www/cordova_all.min.js \
    tmp/ios/platforms/android/assets/www/cordova_all.xl.js
rm tmp/ios/platforms/android/assets/www/cordova_all.xl.js

# Build the app.
cd tmp/ios
../../node_modules/.bin/cordova build --platform android --debug
../../node_modules/.bin/cordova build --platform android --release
../../node_modules/.bin/cordova build --platform ios --debug --emulator
../../node_modules/.bin/cordova build --platform ios --release --device || true
cd ../..

# Sign the Android release app.
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore keys/android/release.keystore -storepass 'store-password' \
    -keypass 'key-password' \
    -signedjar \
    tmp/ios/platforms/android/ant-build/CordovaApp-release-unaligned.apk \
    tmp/ios/platforms/android/ant-build/CordovaApp-release-unsigned.apk \
    android_release
rm -f "tmp/ios/platforms/android/ant-build/CordovaApp-release.apk"
zipalign 4 \
    tmp/ios/platforms/android/ant-build/CordovaApp-release-unaligned.apk \
    tmp/ios/platforms/android/ant-build/CordovaApp-release.apk

# Bring the app up.
mkdir -p bin
cp "tmp/ios/platforms/android/ant-build/CordovaApp-debug.apk" \
    "bin/$APP_NAME-cordova-debug.apk"
cp "tmp/ios/platforms/android/ant-build/CordovaApp-release.apk" \
    "bin/$APP_NAME-cordova-release.apk" || true
rm -rf "bin/$APP_NAME.app"
rm -rf "bin/$APP_NAME-debug.app"
rm -rf "bin/$APP_NAME-release.app"
mv tmp/ios/platforms/ios/build/emulator/*.app "bin/$APP_NAME.app"
mv "bin/$APP_NAME.app" "bin/$APP_NAME-debug.app"
mv "tmp/ios/platforms/ios/build/device/$APP_NAME.app" "bin/$APP_NAME.app" || true
mv "bin/$APP_NAME.app" "bin/$APP_NAME-release.app" || true
