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

# Generate logo variations.
# Names lifted from https://issues.apache.org/jira/browse/CB-2606
mkdir -p tmp/ios/res/android
mkdir -p tmp/ios/res/ios
convert app/img/$APP_LOGO -resize 36x36 -gravity center -background none \
    -extent 36x36 tmp/ios/res/android/ldpi.png
convert app/img/$APP_LOGO -resize 48x48 -gravity center -background none \
    -extent 48x48 tmp/ios/res/android/mdpi.png
convert app/img/$APP_LOGO -resize 72x72 -gravity center -background none \
    -extent 72x72 tmp/ios/res/android/hdpi.png
convert app/img/$APP_LOGO -resize 96x96 -gravity center -background none \
    -extent 96x96 tmp/ios/res/android/xhdpi.png
convert app/img/$APP_LOGO -resize 29x29 -gravity center -extent 29x29 \
    tmp/ios/res/ios/icon-small.png
convert app/img/$APP_LOGO -resize 40x40 -gravity center -extent 40x40 \
    tmp/ios/res/ios/icon-40.png
convert app/img/$APP_LOGO -resize 50x50 -gravity center -extent 50x50 \
    tmp/ios/res/ios/icon-50.png
convert app/img/$APP_LOGO -resize 57x57 -gravity center -extent 57x57 \
    tmp/ios/res/ios/icon.png
convert app/img/$APP_LOGO -resize 58x58 -gravity center -extent 58x58 \
    tmp/ios/res/ios/icon-small@2x.png
convert app/img/$APP_LOGO -resize 60x60 -gravity center -extent 60x60 \
    tmp/ios/res/ios/icon-60.png
convert app/img/$APP_LOGO -resize 72x72 -gravity center -extent 72x72 \
    tmp/ios/res/ios/icon-72.png
convert app/img/$APP_LOGO -resize 76x76 -gravity center -extent 76x76 \
    tmp/ios/res/ios/icon-76.png
convert app/img/$APP_LOGO -resize 80x80 -gravity center -extent 80x80 \
    tmp/ios/res/ios/icon-40@2x.png
convert app/img/$APP_LOGO -resize 100x100 -gravity center -extent 100x100 \
    tmp/ios/res/ios/icon-50@2x.png
convert app/img/$APP_LOGO -resize 114x114 -gravity center -extent 114x114 \
    tmp/ios/res/ios/icon@2x.png
convert app/img/$APP_LOGO -resize 120x120 -gravity center -extent 120x120 \
    tmp/ios/res/ios/icon-60@2x.png
convert app/img/$APP_LOGO -resize 144x144 -gravity center -extent 144x144 \
    tmp/ios/res/ios/icon-72@2x.png
convert app/img/$APP_LOGO -resize 152x152 -gravity center -extent 152x152 \
    tmp/ios/res/ios/icon-76@2x.png
convert app/img/$APP_LOGO -resize 180x180 -gravity center -extent 180x180 \
    tmp/ios/res/ios/icon-60@3x.png

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
    > tmp/ios/platforms/android/platform_www/cordova_all.xl.js
node_modules/.bin/uglifyjs --screw-ie8 -c -m \
    -o tmp/ios/platforms/android/platform_www/cordova_all.min.js \
    tmp/ios/platforms/android/platform_www/cordova_all.xl.js
rm tmp/ios/platforms/android/platform_www/cordova_all.xl.js

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
