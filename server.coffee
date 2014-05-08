port = process.env.PORT or 5000
WebSocketServer = require("ws").Server
server = new WebSocketServer(port: port)
totalConnections = 0
timeSpent =
  "sending data" : 0
  "parsing data" : 0


logStats = ->
  if server.clients.length % 100 is 0 or totalConnections % 100 is 0
    console.log "#{totalConnections} connections since server started"
    console.log "#{server.clients.length} connected clients"
  for key, value of timeSpent
    value = Math.floor(value / 1000)
    console.log "time spent #{key}: #{value} secs"

server.broadcast = (data)->
  for client in @clients
    start = (new Date()).getTime()
    client.send data
    timeSpent["sending data"] += (new Date()).getTime() - start


server.on "connection", (socket) ->
  totalConnections++
  logStats()

  socket.on "message", (data) ->
    start = (new Date()).getTime()
    message = JSON.parse(data)
    timeSpent["parsing data"] += (new Date()).getTime() - start
    console.log("received ping from %s", message.socketNum) if message.action == 'ping'
    console.log("received: %s", message.message) if message.action == 'broadcast'
    server.broadcast data unless message.action == 'ping'

  socket.on "close", ->
    logStats()

