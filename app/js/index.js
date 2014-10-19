(function() {
  var onDeviceReady = function() {
    document.getElementById('iframe').src = 'https://rumbly.herokuapp.com';
  };
  var onMessage = function(event) {
    if (event.data === 'hook-me-up-cordova') {
      var iframe = document.getElementById('iframe');
      var platform = {};
      iframe.contentWindow.cordovaPlatform = platform;
      var properties = Object.getOwnPropertyNames(window);
      var _length = properties.length;
      for(var index = 0; index < _length; ++index) {
        var name = properties[index];
        platform[name] = window[name];
      }
      iframe.contentWindow.postMessage('cordova-hooked-you-up', '*');
    }
  };
  document.addEventListener('deviceready', onDeviceReady, false);
  window.addEventListener('message', onMessage, false);
})();
