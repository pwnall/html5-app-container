(function() {
  var onDeviceReady = function() {
    var iframe = document.getElementById('iframe');
    window.iframe = iframe;
    iframe.src = 'https://rumbly.herokuapp.com';
  };
  var onMessage = function(event) {
    var iframe = document.getElementById('iframe');

    if (event.data === 'html5-app-container-wire-me') {
      var platform = {};
      iframe.contentWindow.cordovaPlatform = platform;
      var properties = Object.getOwnPropertyNames(window);
      var _length = properties.length;
      for(var index = 0; index < _length; ++index) {
        var name = properties[index];
        platform[name] = window[name];
      }
      iframe.contentWindow.postMessage('html5-app-container-wired-you', '*');
    }

    if (event.data.substring(0, 25) === 'html5-app-container-eval|') {
      var javaScript = event.data.substring(25);
      var result = null;
      try {
        result = window.eval(javaScript);
      } catch(e) {
        result = e;
      }
      iframe.contentWindow.postMessage(
          'html5-app-container-evaled|' + result, '*');
    }
  };
  document.addEventListener('deviceready', onDeviceReady, false);
  window.addEventListener('message', onMessage, false);
})();
