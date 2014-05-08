port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0

logClientCount = ->
  if server.clients.length % 100 is 0 or totalConnections % 100 is 0
    console.log "#{totalConnections} connections since server started"
    console.log "#{server.clients.length} connected clients"

server.broadcast = (data)->
  for client in @clients
    client.send data


server.on "connection", (socket) ->
  totalConnections++
  logClientCount()

  socket.on "message", (data) ->
    message = JSON.parse(data)
    console.log("received ping from %s", message.socketNum) if message.action == 'ping'
    console.log("received: %s", message.message) if message.action == 'broadcast'
    server.broadcast data unless message.action == 'ping'

  socket.on "close", ->
    logClientCount()

