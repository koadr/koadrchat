module.exports = (app, server) ->

  chat_room = require('socket.io').listen(server)
  chatter   = require('chatter')

  unless app.settings.chat_room
    app.set 'chat_room', chat_room

  chatter.set_sockets(chat_room.sockets)

  chat_room.sockets.on 'connection', (socket) ->
    chatter.connect_chatter
      socket: socket
      username: "Blue Drawers"