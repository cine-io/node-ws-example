port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0
currentConnections = 0

logClientCount = ->
  if numConnections % 100 is 0
    console.log "#{totalConnections} total clients"
    console.log "#{currentConnections} current clients"

server.on "connection", (socket) ->
  totalConnections++
  currentConnections++
  logClientCount()

  socket.on "message", (message) ->
    console.log "received: %s bytes", message.length
    socket.send message unless message.match(/^ping/)

  socket.on "close", ->
    currentConnections--
    logClientCount()
