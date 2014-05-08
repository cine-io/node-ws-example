port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0
clients = []

logClientCount = ->
  if clients.length % 100 is 0 or totalConnections % 100 is 0
    console.log "#{totalConnections} connections"
    console.log "#{clients.length} connected clients"

broadcast = (data)->
  clients.forEach (socket)->
    socket.send data

close = (socketToClose)->
  whichIndex = clients.indexOf(socketToClose)
  delete clients[whichIndex] if whichIndex > 0
  logClientCount()


server.on "connection", (socket) ->
  totalConnections++
  clients.push socket
  logClientCount()

  socket.on "message", (data) ->
    message = JSON.parse(data)
    console.log("recieved ping from %s", message.socketNum) if message.action == 'ping'
    console.log("received: %s", message.message) if message.action == 'broadcast'
    broadcast data unless message.action == 'ping'

  socket.on "close", close

