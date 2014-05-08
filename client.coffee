WebSocket = require("ws")
serverUrl = process.argv[3] || "ws://node-ws-example-gs.herokuapp.com"
defaultPingInterval = 25
messageWaitTime = 10
sockets = []
receivedCount = {}

ping = (socket, socketNum, pingInterval)->
  keepPinging = ->
    messageData = JSON.stringify({ action: 'ping', socketNum: socketNum })
    socket.send messageData
    setTimeout keepPinging, pingInterval*1000
  keepPinging()

reportAndDeleteIfAllReceived = (message, numSockets)->
  console.log "" + receivedCount[message] + " clients received " + message
  delete receivedCount[message] if receivedCount[message.message] == numSockets

newSocket = (socketNum, numSockets, pingInterval)->
  socket = new WebSocket(serverUrl)

  socket.on 'open', ->
    sockets.push socket
    console.log "#{sockets.length} clients connected" if sockets.length == numSockets or sockets.length % 100 is 0
    ping socket, socketNum, defaultPingInterval

  socket.on 'message', (data, flags)->
    message = JSON.parse(data)
    receivedCount[message.message]++
    reportReceived = ->
      reportAndDeleteIfAllReceived message.message, numSockets
    # wait some number of seconds after receiving the first message to report back
    setTimeout(reportReceived, messageWaitTime*1000) if receivedCount[message.message] == 1

  socket.on 'close', ->
    console.log "socket", socketNum, "closed"

sendAMessageEverySecond = (numSockets)->
  doIt = ->
    if sockets.length == numSockets
      whichSocket = Math.floor(Math.random() * sockets.length)
      message = (new Date()).getTime()
      receivedCount[message] = 0
      messageData = JSON.stringify({ action: 'broadcast', socketNum: whichSocket, message: message })
      sockets[whichSocket].send messageData
    setTimeout doIt, 1000
  doIt()

run = ->
  numSockets = parseInt(process.argv[2]) || 10
  # create all of the clients first
  numConnected = 0
  for i in [0..numSockets-1]
    newSocket i, numSockets, defaultPingInterval

  sendAMessageEverySecond numSockets

run() if !module.parent
