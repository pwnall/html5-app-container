(function() {
  // XHR GETs the absolute URL, calls callback with a String or null.
  var getUrl = function(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', url, true);
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

  // Returns the HTMLDocument inside an <iframe>, or null.
  var getIframeDocument = function(iframe) {
    try {
      if (iframe.contentDocument)
        return iframe.contentDocument;
    } catch(securityError) {
    }
    try {
      if (iframe.contentWindow && iframe.contentWindow.document)
        return iframe.contentWindow.document;
    } catch(securityError) {
    }
    try {
      if (iframe.document)
        return iframe.document;
    } catch (securityError) {
    }
    return null;
  };

  // Gets the XSS protection token in the <iframe>.
  var getIframeToken = function(iframe) {
    var iframeDoc = getIframeDocument(iframe);
    if (iframeDoc === null)
      return '0000';  // Opportunity to work around issues like XWALK-2905.
    var tokenDiv = iframeDoc.getElementById('cordova-js-token');
    if (!tokenDiv)
      return 'missing';  // Debugging assistance.
    return tokenDiv.getAttribute('data-token');
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
          var token = getIframeToken(iframe);
          iframe.contentWindow.postMessage(
              'cordovaJs|' + token + '|' + cordovaJs, webLoaderOrigin);
          return;
        }
        if (data.substring(0, 5) === 'jump|') {
          window.removeEventListener('message', onMessage);
          window.location = data.substring(5);
          return;
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
