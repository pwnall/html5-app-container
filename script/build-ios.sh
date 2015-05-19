#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.
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
mkdir -p cordova/res/ios
convert app/img/$APP_LOGO -resize 29x29 -gravity center -extent 29x29 \
    cordova/res/ios/icon-small.png
convert app/img/$APP_LOGO -resize 40x40 -gravity center -extent 40x40 \
    cordova/res/ios/icon-40.png
convert app/img/$APP_LOGO -resize 50x50 -gravity center -extent 50x50 \
    cordova/res/ios/icon-50.png
convert app/img/$APP_LOGO -resize 57x57 -gravity center -extent 57x57 \
    cordova/res/ios/icon.png
convert app/img/$APP_LOGO -resize 58x58 -gravity center -extent 58x58 \
    cordova/res/ios/icon-small@2x.png
convert app/img/$APP_LOGO -resize 60x60 -gravity center -extent 60x60 \
    cordova/res/ios/icon-60.png
convert app/img/$APP_LOGO -resize 72x72 -gravity center -extent 72x72 \
    cordova/res/ios/icon-72.png
convert app/img/$APP_LOGO -resize 76x76 -gravity center -extent 76x76 \
    cordova/res/ios/icon-76.png
convert app/img/$APP_LOGO -resize 80x80 -gravity center -extent 80x80 \
    cordova/res/ios/icon-40@2x.png
convert app/img/$APP_LOGO -resize 100x100 -gravity center -extent 100x100 \
    cordova/res/ios/icon-50@2x.png
convert app/img/$APP_LOGO -resize 114x114 -gravity center -extent 114x114 \
    cordova/res/ios/icon@2x.png
convert app/img/$APP_LOGO -resize 120x120 -gravity center -extent 120x120 \
    cordova/res/ios/icon-60@2x.png
convert app/img/$APP_LOGO -resize 144x144 -gravity center -extent 144x144 \
    cordova/res/ios/icon-72@2x.png
convert app/img/$APP_LOGO -resize 152x152 -gravity center -extent 152x152 \
    cordova/res/ios/icon-76@2x.png
convert app/img/$APP_LOGO -resize 180x180 -gravity center -extent 180x180 \
    cordova/res/ios/icon-60@3x.png

# Bundle Cordova's platform files.
# NOTE: the iOS build clears its www folder, but it copies the contents of
#       platform_www in it, so we can stash our code there
node_modules/.bin/coffee script/merge-plugins.coffee \
    cordova/platforms/ios/www/cordova.js \
    cordova/platforms/ios/www/cordova_plugins.js \
    cordova/platforms/ios/platform_www/cordova_all.xl.js
node_modules/.bin/uglifyjs --screw-ie8 -c -m \
    -o cordova/platforms/ios/platform_www/cordova_all.min.js \
    cordova/platforms/ios/platform_www/cordova_all.xl.js
rm cordova/platforms/ios/platform_www/cordova_all.xl.js

# Build the app.
cd cordova
../node_modules/.bin/cordova build --platform ios --debug --emulator
../node_modules/.bin/cordova build --platform ios --release --device || true
cd ..

# Copy the binaries to bin/.
mkdir -p bin
rm -rf "bin/$APP_NAME.app"
rm -rf "bin/$APP_NAME-debug.app"
rm -rf "bin/$APP_NAME-release.app"
mv cordova/platforms/ios/build/emulator/*.app "bin/$APP_NAME.app"
mv "bin/$APP_NAME.app" "bin/$APP_NAME-debug.app"
mv "cordova/platforms/ios/build/device/$APP_NAME.app" "bin/$APP_NAME.app" || true
mv "bin/$APP_NAME.app" "bin/$APP_NAME-release.app" || true
