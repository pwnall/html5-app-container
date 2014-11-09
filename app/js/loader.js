// XHR GETs the page-relative URL, calls callback with a String or null.
var getUrl = function(relativeUrl, callback) {
  var pageUrl = window.location.href;
  var slash = pageUrl.lastIndexOf('/');
  var absoluteUrl = pageUrl.substring(0, slash + 1) + relativeUrl;

  var xhr = new XMLHttpRequest();
  xhr.open('GET', absoluteUrl, false);
  xhr.onreadystatechange = function() {
    if (xhr.readyState !== 4)
      return;
    var data = xhr.responseText || xhr.response;
    callback(data);
  };
  xhr.send();
};

// XHR GETs the plugin list, calls callback with an Array or null.
var loadPluginList = function(callback) {
  getUrl('cordova_plugins.js', function(js) {
    var match = js.match(/module\.exports\s*=\s*(\[[\s\S]*\]);/i);
    var rawList = JSON.parse(match[1]);

    // Add entries for cordova.js and cordova_plugins.js.
    var pseudoEntries = [
      { file: 'cordova.js' },
      { file: 'cordova_plugins.js', _contents: js }
    ];
    callback(pseudoEntries.concat(rawList));
  });
};

// Loads all the Cordova plugins via XHR, calls callback with a String
// containing the concatenated JavaScript.
var loadPlugins = function(pluginList, callback) {
  var length = pluginList.length;
  var scripts = new Array(length);
  var scriptsLeft = length;
  for (var _i = 0; _i < length; ++_i) {
    // Optimization: don't fetch already-fetched script.
    var plugin = pluginList[_i];
    if ('_contents' in plugin) {
      scripts[_i] = plugin._contents;
      scriptsLeft -= 1;
      continue;
    }

    (function(i) {
      getUrl(pluginList[i].file, function(js) {
        scripts[i] = js;
        scriptsLeft -= 1;
        if (scriptsLeft === 0)
          callback(scripts.join(";\n"));
      });
    })(_i);
  }
};

// Implements the communication protocol with the Web-side Cordova loader.
var webLoaderProtocol = function(cordovaJs) {
  getUrl('web_url.txt', function(webLoaderUrl) {
    var webLoaderOrigin = webLoaderUrl.match(/^(\w+:\/\/*[^\/]+)\//)[1];
    console.log(webLoaderOrigin);

    var iframe = document.createElement('iframe');
    iframe.src = webLoaderUrl;
    iframe.style.display = 'none';
    document.body.appendChild(iframe);

    var onMessage = function(event) {
      if (event.origin !== webLoaderOrigin)
        return;
      var data = event.data;
      if (data === 'getjs') {
        iframe.contentWindow.postMessage(cordovaJs, webLoaderOrigin);
        return;
      }
      if (data.substring(0, 5) === 'jump|') {
        window.removeEventListener('message', onMessage);
        window.location = data.substring(5);
      }
    };
    window.addEventListener('message', onMessage, false);
  });
}

// Load the Cordova plugins, postMessage the contents to the parent frame.
loadPluginList(function(pluginList) {
  loadPlugins(pluginList, function(cordovaJs) {
    webLoaderProtocol(cordovaJs);
  });
});
