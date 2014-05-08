var port = process.env.PORT || 5000;
var WebSocketServer = require('ws').Server
  , wss = new WebSocketServer({port: port})
  , numConnections = 0;
wss.on('connection', function(ws) {
    numConnections++;
    if (numConnections % 100 === 0) {
      console.log('connected', numConnections, 'clients');
    }
    ws.on('message', function(message) {
        console.log('received: %s bytes', message.length);
        if (!message.match(/^ping/)) ws.send(message);
    });
});
