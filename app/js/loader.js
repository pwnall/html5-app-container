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

// Implements the communication protocol with the Web-side Cordova loader.
var webLoaderProtocol = function(cordovaJs) {
  getUrl('web_url.txt', function(webUrlTxt) {
    var webLoaderUrl = webUrlTxt.trim();
    var webLoaderOrigin = webLoaderUrl.match(/^(\w+:\/\/*[^\/]+)\//)[1];

    var iframe = document.createElement('iframe');
    iframe.src = webLoaderUrl;
    iframe.style.display = 'none';
    document.body.appendChild(iframe);

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
}

// Load the Cordova plugins, postMessage the contents to the parent frame.
getUrl('cordova_all.min.js', function (cordovaJs) {
  webLoaderProtocol(cordovaJs);
});
