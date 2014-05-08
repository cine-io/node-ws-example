var port = process.env.PORT || 5000;
var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({port: port})
  , totalConnections = 0
  , currentConnections = 0;
wss.on('connection', function(ws) {
  totalConnections++;
  currentConnections++;

  if (totalConnections % 100 === 0) {
    console.log(totalConnections, 'total clients');
    console.log(currentConnections, 'current clients');
  }

  ws.on('message', function(message) {
      console.log('received: %s bytes', message.length);
      if (!message.match(/^ping/)) ws.send(message);
  });

  ws.on('close', function() {
    currentConnections--;
    // console.log('client disconnected');
  });

});
