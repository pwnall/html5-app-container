#!/bin/bash

set -o errexit     # Stop the script on the first error.
set -o nounset     # Catch un-initialized variables.
set +o histexpand  # No history expansion, because of arcane ! treatment.

# Import configuration variables.
. script/vars.sh

# Copy files into app.
rm -f cordova/www/master.css
rm -f cordova/www/main.js
rm -rf cordova/www/css
rm -rf cordova/www/img
rm -rf cordova/www/js
cp -r app/* cordova/www/
cp app/config.xml cordova/

# Generate logo variations.
# Names lifted from https://issues.apache.org/jira/browse/CB-2606
mkdir -p cordova/res/android
convert app/img/$APP_LOGO -resize 36x36 -gravity center -background none \
    -extent 36x36 cordova/res/android/ldpi.png
convert app/img/$APP_LOGO -resize 48x48 -gravity center -background none \
    -extent 48x48 cordova/res/android/mdpi.png
convert app/img/$APP_LOGO -resize 72x72 -gravity center -background none \
    -extent 72x72 cordova/res/android/hdpi.png
convert app/img/$APP_LOGO -resize 96x96 -gravity center -background none \
    -extent 96x96 cordova/res/android/xhdpi.png


# Bundle Cordova's platform files.
cat cordova/platforms/android/assets/www/cordova.js \
    cordova/platforms/android/assets/www/cordova_plugins.js \
    cordova/platforms/android/assets/www/plugins/org.chromium.*/*.js \
    cordova/platforms/android/assets/www/plugins/org.chromium.*/*/*.js \
    cordova/platforms/android/assets/www/plugins/org.chromium.*/*/*/*.js \
    cordova/platforms/android/assets/www/plugins/cordova-*/www/*.js \
    cordova/platforms/android/assets/www/plugins/cordova-*/www/android/*.js \
    > cordova/platforms/android/platform_www/cordova_all.xl.js
node_modules/.bin/uglifyjs --screw-ie8 -c -m \
    -o cordova/platforms/android/platform_www/cordova_all.min.js \
    cordova/platforms/android/platform_www/cordova_all.xl.js
rm cordova/platforms/android/platform_www/cordova_all.xl.js

# Workaround Android Ant configuration bug.
# https://code.google.com/p/android/issues/detail?id=67510
#echo "java.source=1.7" > cordova/ant.properties
#echo "java.target=1.7" >> cordova/ant.properties

# Build the app.
cd cordova
../node_modules/.bin/cordova build --platform android --debug
../node_modules/.bin/cordova build --platform android --release
cd ..

# Sign the release app.
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore keys/android/release.keystore -storepass 'store-password' \
    -keypass 'key-password' \
    -signedjar \
    cordova/platforms/android/build/outputs/apk/android-armv7-release-unaligned.apk \
    cordova/platforms/android/build/outputs/apk/android-armv7-release-unsigned.apk \
    android_release
rm -f cordova/platforms/android/build/outputs/apk/android-armv7-release.apk
zipalign 4 \
    cordova/platforms/android/build/outputs/apk/android-armv7-release-unaligned.apk \
    cordova/platforms/android/build/outputs/apk/android-armv7-release.apk
jarsigner -sigalg SHA1withRSA -digestalg SHA1 \
    -keystore keys/android/release.keystore -storepass 'store-password' \
    -keypass 'key-password' \
    -signedjar \
    cordova/platforms/android/build/outputs/apk/android-x86-release-unaligned.apk \
    cordova/platforms/android/build/outputs/apk/android-x86-release-unsigned.apk \
    android_release
rm -f cordova/platforms/android/build/outputs/apk/android-x86-release.apk
zipalign 4 \
    cordova/platforms/android/build/outputs/apk/android-x86-release-unaligned.apk \
    cordova/platforms/android/build/outputs/apk/android-x86-release.apk

# Copy the binaries to bin/.
mkdir -p bin
cp cordova/platforms/android/build/outputs/apk/android-armv7-debug.apk \
    "bin/$APP_NAME-armv7-debug.apk"
cp cordova/platforms/android/build/outputs/apk/android-x86-debug.apk \
    "bin/$APP_NAME-x86-debug.apk"
cp cordova/platforms/android/build/outputs/apk/android-armv7-release.apk \
    "bin/$APP_NAME-armv7-release.apk"
cp cordova/platforms/android/build/outputs/apk/android-x86-release.apk \
    "bin/$APP_NAME-x86-release.apk"
