port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0
clients = []

logClientCount = ->
  if clients.length % 100 is 0
    console.log "#{totalConnections} connections since server started"
    console.log "#{clients.length} connected clients"

broadcast = (data)->
  clients.forEach (socket)->
    socket.send(data) if socket


server.on "connection", (socket) ->
  totalConnections++
  clients.push socket
  logClientCount()

  socket.on "message", (data) ->
    message = JSON.parse(data)
    console.log("received ping from %s", message.socketNum) if message.action == 'ping'
    console.log("received: %s", message.message) if message.action == 'broadcast'
    server.broadcast data unless message.action == 'ping'

  socket.on "close", ->
    which = clients.indexOf(socket)
    if which > 0
      clients.splice(which, 1)
    logClientCount()

server.broadcast = (data)->
  for client in @clients
    client.send data
