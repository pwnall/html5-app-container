#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh

# Get plugman for Cordova.
npm install plugman

# Get browserify for JS bundle.
npm install browserify

# Get Crosswalk-Cordova.
XWALK_VER=10.39.235.4
if [ ! -f crosswalk_cordova/bin/create ] ; then
  mkdir -p crosswalk_cordova
  cd crosswalk_cordova
  curl --output sdk.zip \
      "https://download.01.org/crosswalk/releases/crosswalk/android/beta/$XWALK_VER/arm/crosswalk-cordova-$XWALK_VER-arm.zip"
  unzip sdk.zip
  rm sdk.zip
  mv crosswalk-cordova-*/* .
  cd ..
fi

# Create Crosswalk-Cordova application.
mkdir -p tmp/android
rm -rf tmp/android
crosswalk_cordova/bin/create tmp/android "$APP_PACKAGE" "$APP_NAME"
cp app/config.xml tmp/android/res/xml/
cd tmp/android

# Patch in https://github.com/crosswalk-project/crosswalk-cordova-android/pull/147
sed -i '' \
    's/this.appView.bridge.getMessageQueue().reset();/this.appView.bridge.reset(url);/' \
    CordovaLib/src/org/apache/cordova/CordovaChromeClient.java

# Plugins. Add everything to get decent permission bits.
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.battery-status
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.camera
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.console
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.device
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.device-motion
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.device-orientation
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.dialogs
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.file
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.geolocation
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.globalization
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.media
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.media-capture
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.network-information
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.speech.speechsynthesis
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.statusbar
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.apache.cordova.vibration

# Chrome Apps plugins.
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.alarms
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.audiocapture
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.filesystem
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.idle
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.notifications
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.polyfill.blob_constructor
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.polyfill.customevent
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.polyfill.xhr_features
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.power
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.storage
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.system.cpu
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.system.display
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.system.memory
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.system.network
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.system.storage
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.videocapture
../../node_modules/.bin/plugman install --platform android --project ./ --plugin \
    org.chromium.zip

# Create key store.
cd ../..
if [ ! -f keys/android/release.keystore ] ; then
  mkdir -p keys/android
  cd keys/android
  keytool -genkey -keystore release.keystore -storepass 'store-password' \
      -keyalg RSA -keypass 'key-password' -keysize 2048 -validity 10000 \
      -dname "CN=$APP_NAME, C=US" \
      -alias android_release
  cd ../..
fi
