var SocketHelper =  {
  init: function(channel, user, callbacks) {
    var url = 'ws://localhost:3001/talk?channel=' + channel + '&user=' + user;
    var ws = new WebSocket(url);
    ws.onmessage = function(m) {
      var payload = m.data;
      if (typeof(payload) !== 'object') {
        payload = JSON.parse(payload);
      }
      payload = payload.body;
      payload.timeStamp = m.timeStamp;
      callbacks.onmessage(payload);
    };
    ws.onclose = function(e) {
      callbacks.onmessage({ action: "leave", user: user, channel: channel });
    };
    return ws;
  }
};
