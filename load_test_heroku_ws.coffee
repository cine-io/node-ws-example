express = require('express')
http = require('http')
WebSocket = require('ws')
app = express()
server = http.createServer(app)
_ = require('underscore')

SERVER_URL = "ws://node-ws-example-gs.herokuapp.com/path"

numberOfUsersToConnect = Number(process.argv[2])
clc = require "cli-color"
createClientTimeout = 0
async = require 'async'
shuttingDown = false

class ClientManager

  constructor: ->
    @clients = []
    @messages = {}
    @connections = 0
    @allConnected = false

  run: (done)->
    console.log('connecting total clients', numberOfUsersToConnect)
    times = [1..numberOfUsersToConnect]
    async.each times, @_addNewClient, done

  disconnectAllClients: ->
    _.invoke @clients, 'disconnectPermantly'

  clientConnected: (client)->
    if client.connectionIndex
      return console.log("Client reconnecting", client.connectionIndex)
    connectionIndex = ++@connections
    console.log "#{connectionIndex}/#{numberOfUsersToConnect} connected! (#{Date.now() - client.createdAt} ms)" if connectionIndex % 100 == 0
    client.setConnectionIndex(connectionIndex)
    @allConnected = true if connectionIndex == numberOfUsersToConnect

  _addNewClient: (index, callback)=>
    # console.log('added client', index)
    return if shuttingDown
    @clients.push new WsClient(index, this, SERVER_URL, callback)

  recieveClientMessage: (client, message)->
    @messages[message] ||= []
    @messages[message].push(client.connectionIndex)
    # console.log(client.connectionIndex, message)
    if @messages[message].length == @connections
      logMessageCount(@connections, message)
      delete @messages[message]

logMessageCount = (count, message)->
  console.log("#{count} clients recieved message", message)


class WsClient

  constructor: (@index, @manager, @server_url, @callback)->
    @createdAt = new Date
    # Establish socket connection to the node server:
    @createSocket()

  createSocket: =>
    @socket = new WebSocket(@server_url)
    @socket.on 'open', =>
      @manager.clientConnected(this)
      # console.log('calling back', @index)
      # @_subscribeToHealth()
      # @_keepPinging()
      setTimeout @callback, createClientTimeout

    @socket.on 'message', (data, flags)=>
      message = data.message || data
      @manager.recieveClientMessage(this, message)

    @socket.on 'error', (message)=>
      console.log clc.blueBright(@connectionIndex), 'error', message

    @socket.on 'close', =>
      console.log clc.blueBright(@connectionIndex), 'closing'

  _subscribeToHealth: =>
    @socket.send action: 'join', room: 'health'

  _keepPinging: =>
    ping = =>
      @socket.send 'ping ' + @index
    setInterval ping, 25000

  setConnectionIndex: (@connectionIndex)->

  disconnectPermantly: ->
    clearInterval 'ping'
    @socket.close()

  postMessage: (message) ->
    console.log('sending message', message)
    @socket.send (new Date()).toString()

shouldPostMessage = process.argv[3] == 'post'

scheduleMessage = ->
  setTimeout postMessage, 1000 if shouldPostMessage

postMessage = ->
  return if shuttingDown
  clientToSend = clientManager.clients[0]
  now = new Date
  clientToSend.postMessage now.toISOString()
  scheduleMessage()


scheduleWhereYouAt = ->
  setTimeout whereYouAt, 3000

whereYouAt = ->
  messageTtlSeconds = 60
  messageTtl = new Date
  messageTtl.setSeconds(messageTtl.getSeconds() - messageTtlSeconds)
  _.each clientManager.messages, (recievedClients, message)->
    try
      d = new Date(message)
      delete clientManager.messages[message] if messageTtl > d
    catch e
    console.log("only #{recievedClients.length} recieved message", message)
  scheduleWhereYouAt()

scheduleWhereYouAt()

clientManager = new ClientManager
clientManager.run(scheduleMessage)


process.on 'SIGINT', ->
  process.exit() if shuttingDown
  timeToShutDown = 1
  console.log( "Gracefully shutting down in #{timeToShutDown} seconds from SIGINT (Ctrl-C)" )
  clientManager.disconnectAllClients()
  setTimeout process.exit, timeToShutDown * 1000
  shuttingDown = true


# ulimit -S -n 1048576
# If you want to test in the browser
# App.socket.emit('subscribe', 'health')
# App.socket.emit('health', (new Date).toISOString())
# App.socket.on('health', function(message) {console.log('got health', message)})
# App.socket.on('total-connected', function(data) {console.log('got connected', data)})
