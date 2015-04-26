#!/bin/bash

set -o errexit     # Stop the script on the first error.
set -o nounset     # Catch un-initialized variables.
set +o histexpand  # No history expansion, because of arcane ! treatment.

# Import configuration variables.
. script/vars.sh

# Get Cordova.
npm install cordova

# Get minifier for Cordova's platform JavaScript.
npm install uglify-js

# Get deploy tools.
npm install ios-deploy
npm install ios-sim

# Create generic Cordova application.
rm -rf cordova/
mkdir -p cordova/
node_modules/.bin/cordova create ./cordova "$APP_PACKAGE" "$APP_NAME"
cd cordova

# TODO(pwnall): consider adding Firefox OS / Windows / etc.
../node_modules/.bin/cordova platform add ios
../node_modules/.bin/cordova platform add android

# Plugins. Add everything to get decent permission bits.
../node_modules/.bin/cordova plugin add cordova-plugin-battery-status
../node_modules/.bin/cordova plugin add cordova-plugin-camera
../node_modules/.bin/cordova plugin add cordova-plugin-console
../node_modules/.bin/cordova plugin add cordova-plugin-device
../node_modules/.bin/cordova plugin add cordova-plugin-device-motion
../node_modules/.bin/cordova plugin add cordova-plugin-device-orientation
../node_modules/.bin/cordova plugin add cordova-plugin-dialogs
../node_modules/.bin/cordova plugin add cordova-plugin-file
../node_modules/.bin/cordova plugin add cordova-plugin-geolocation
../node_modules/.bin/cordova plugin add cordova-plugin-globalization
../node_modules/.bin/cordova plugin add cordova-plugin-media
../node_modules/.bin/cordova plugin add cordova-plugin-media-capture
../node_modules/.bin/cordova plugin add cordova-plugin-network-information
#../node_modules/.bin/cordova plugin add cordova-plugin-speech-speechsynthesis
../node_modules/.bin/cordova plugin add cordova-plugin-statusbar
../node_modules/.bin/cordova plugin add cordova-plugin-vibration
../node_modules/.bin/cordova plugin add cordova-plugin-whitelist

# Chrome Apps plugins.
../node_modules/.bin/cordova plugin add org.chromium.alarms
../node_modules/.bin/cordova plugin add org.chromium.audiocapture
../node_modules/.bin/cordova plugin add org.chromium.bluetooth
../node_modules/.bin/cordova plugin add org.chromium.bluetoothlowenergy
../node_modules/.bin/cordova plugin add org.chromium.bluetoothsocket
../node_modules/.bin/cordova plugin add org.chromium.filesystem
../node_modules/.bin/cordova plugin add org.chromium.idle
../node_modules/.bin/cordova plugin add org.chromium.notifications
../node_modules/.bin/cordova plugin add org.chromium.polyfill.blob_constructor
../node_modules/.bin/cordova plugin add org.chromium.polyfill.customevent
../node_modules/.bin/cordova plugin add org.chromium.polyfill.xhr_features
../node_modules/.bin/cordova plugin add org.chromium.power
../node_modules/.bin/cordova plugin add org.chromium.storage
../node_modules/.bin/cordova plugin add org.chromium.system.cpu
../node_modules/.bin/cordova plugin add org.chromium.system.display
../node_modules/.bin/cordova plugin add org.chromium.system.memory
../node_modules/.bin/cordova plugin add org.chromium.system.network
../node_modules/.bin/cordova plugin add org.chromium.system.storage
../node_modules/.bin/cordova plugin add org.chromium.videocapture
../node_modules/.bin/cordova plugin add org.chromium.zip

# Crosswalk plugin.
../node_modules/.bin/cordova plugin add cordova-plugin-crosswalk-webview

# NFC plugin.
../node_modules/.bin/cordova plugin add com.chariotsolutions.nfc.plugin
