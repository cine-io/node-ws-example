port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0
currentConnections = 0

logClientCount = ->
  if currentConnections % 100 is 0 or totalConnections % 100 is 0
    console.log "#{totalConnections} connections"
    console.log "#{currentConnections} connected clients"

server.on "connection", (socket) ->
  totalConnections++
  currentConnections++
  logClientCount()

  socket.on "message", (data) ->
    message = JSON.parse(data)
    console.log("received: %s bytes", message.message.length) if message.action == 'broadcast'
    socket.send data unless message.action == 'ping'

  socket.on "close", ->
    currentConnections--
    logClientCount()
