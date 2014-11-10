(function() {
  // XHR GETs the absolute URL, calls callback with a String or null.
  var getUrl = function(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, false);
    xhr.onreadystatechange = function() {
      if (xhr.readyState !== 4)
        return;
      var data = xhr.responseText || xhr.response;
      callback(data);
    };
    xhr.send();
  };

  // XHR GETs the page-relative URL, calls callback with a String or null.
  var getPageUrl = function(relativeUrl, callback) {
    var pageUrl = window.location.href;
    var slash = pageUrl.lastIndexOf('/');
    var absoluteUrl = pageUrl.substring(0, slash + 1) + relativeUrl;
    getUrl(absoluteUrl, callback);
  };

  // Loads the given URL in a hidden <iframe>.
  var setupIframe = function(url) {
    var iframe = document.createElement('iframe');
    iframe.src = url;
    iframe.style.display = 'none';
    document.body.appendChild(iframe);
    return iframe;
  };

  // Implements the communication protocol with the Web-side Cordova loader.
  var webLoaderProtocol = function(cordovaJs) {
    getPageUrl('web_url.txt', function(webUrlTxt) {
      var webLoaderUrl = webUrlTxt.trim();
      var webLoaderOrigin = webLoaderUrl.match(/^(\w+:\/\/*[^\/]+)\//)[1];
      var iframe = setupIframe(webLoaderUrl);

      var onMessage = function(event) {
        if (event.origin !== webLoaderOrigin)
          return;
        var data = event.data;
        if (data === 'getjs') {
          iframe.contentWindow.postMessage(
              'cordovaJs|' + cordovaJs, webLoaderOrigin);
          return;
        }
        if (data.substring(0, 5) === 'jump|') {
          window.removeEventListener('message', onMessage);
          window.location = data.substring(5);
        }
      };
      window.addEventListener('message', onMessage, false);
    });
  };

  // Load the Cordova plugins, postMessage the contents to the parent frame.
  getPageUrl('cordova_all.min.js', function (cordovaJs) {
    webLoaderProtocol(cordovaJs);
  });
})();
