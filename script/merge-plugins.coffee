# Merges the JavaScript files in Cordova plugins.
#
# This script reads the array containing plugin defintions in the
# platform-specific cordova_plugins.js file, then reads the plugin JavaScript
# files and concatenates them into a single file.
#
# The script is more accurate than concatenating all the files that match some
# path globs, because plugins don't have a common structure. Some place all
# their sources in www/. Some place sources in the root directory. Some place
# tests together with their code. So, the script is the only sane way of
# handling all that.

fs = require 'fs'
path = require 'path'
vm = require 'vm'

outputFile = process.argv[4]
coreFile = process.argv[2]
coreFileContents = fs.readFileSync coreFile, encoding: 'utf-8'

listFile = process.argv[3]
listFileDir = path.dirname listFile
listModuleId = 'cordova/plugin_list'

cordovaModules = {}
listFileContents = fs.readFileSync listFile, encoding: 'utf-8'
cordovaModules[listModuleId] = listFileContents

# Eval cordova_plugins in a VM to get the module definition.
vmModules = {}
sandbox = cordova:
    define: (moduleName, moduleFunction) ->
      vmModules[moduleName] = moduleFunction
vm.runInNewContext listFileContents, sandbox, filename: listFile

# Run the module definition (hopefully in the same VM) to get the modules list.
vmGlobalModule = exports: []
vmRequire = -> throw new Error("require not supported")
vmModules[listModuleId] vmRequire, vmGlobalModule.exports,
    vmGlobalModule

for moduleDef in vmGlobalModule.exports
  moduleId = moduleDef.id
  relativePath = moduleDef.file
  modulePath = path.join listFileDir, relativePath
  moduleContents = fs.readFileSync modulePath, encoding: 'utf-8'
  cordovaModules[moduleId] = moduleContents

outputPieces = (contents for name, contents of cordovaModules)
fs.writeFileSync outputFile, coreFileContents + outputPieces.join(''),
                 encoding: 'utf-8'
