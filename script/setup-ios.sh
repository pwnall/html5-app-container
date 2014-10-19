#!/bin/bash

set -o errexit  # Stop the script on the first error.
set -o nounset  # Catch un-initialized variables.

# Import configuration variables.
. script/vars.sh

# Get Cordova.
npm install cordova

# Get deploy tools.
npm install ios-deploy
npm install ios-sim

# Create generic Cordova application.
mkdir -p tmp/ios
rm -rf tmp/ios
node_modules/.bin/cordova create ./tmp/ios "$APP_PACKAGE" "$APP_NAME"
cd tmp/ios

# TODO(pwnall): consider adding Firefox OS / Windows / etc.
../../node_modules/.bin/cordova platform add ios
../../node_modules/.bin/cordova platform add android

# Plugins. Add everything to get decent permission bits.
../../node_modules/.bin/cordova plugin add org.apache.cordova.battery-status
../../node_modules/.bin/cordova plugin add org.apache.cordova.camera
../../node_modules/.bin/cordova plugin add org.apache.cordova.console
../../node_modules/.bin/cordova plugin add org.apache.cordova.device
../../node_modules/.bin/cordova plugin add org.apache.cordova.device-motion
../../node_modules/.bin/cordova plugin add org.apache.cordova.device-orientation
../../node_modules/.bin/cordova plugin add org.apache.cordova.dialogs
../../node_modules/.bin/cordova plugin add org.apache.cordova.file
../../node_modules/.bin/cordova plugin add org.apache.cordova.geolocation
../../node_modules/.bin/cordova plugin add org.apache.cordova.globalization
../../node_modules/.bin/cordova plugin add org.apache.cordova.media
../../node_modules/.bin/cordova plugin add org.apache.cordova.media-capture
../../node_modules/.bin/cordova plugin add org.apache.cordova.network-information
../../node_modules/.bin/cordova plugin add org.apache.cordova.speech.speechsynthesis
../../node_modules/.bin/cordova plugin add org.apache.cordova.statusbar
../../node_modules/.bin/cordova plugin add org.apache.cordova.vibration

# Chrome Apps plugins.
../../node_modules/.bin/cordova plugin add org.chromium.power
../../node_modules/.bin/cordova plugin add org.chromium.alarms
../../node_modules/.bin/cordova plugin add org.chromium.audiocapture
../../node_modules/.bin/cordova plugin add org.chromium.filesystem
../../node_modules/.bin/cordova plugin add org.chromium.idle
../../node_modules/.bin/cordova plugin add org.chromium.notifications
../../node_modules/.bin/cordova plugin add org.chromium.polyfill.blob_constructor
../../node_modules/.bin/cordova plugin add org.chromium.polyfill.customevent
../../node_modules/.bin/cordova plugin add org.chromium.polyfill.xhr_features
../../node_modules/.bin/cordova plugin add org.chromium.storage
../../node_modules/.bin/cordova plugin add org.chromium.system.cpu
../../node_modules/.bin/cordova plugin add org.chromium.system.display
../../node_modules/.bin/cordova plugin add org.chromium.system.memory
../../node_modules/.bin/cordova plugin add org.chromium.system.network
../../node_modules/.bin/cordova plugin add org.chromium.system.storage
../../node_modules/.bin/cordova plugin add org.chromium.videocapture
../../node_modules/.bin/cordova plugin add org.chromium.zip
