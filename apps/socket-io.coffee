module.exports = (app, server, mongoose, db, store) ->

  cookie       = require("cookie")
  AllModels    = require('../models/all_models')(mongoose, db)
  User         = AllModels.User

  io           = require('socket.io').listen(server)
  uuid         = require('node-uuid')
  online_users = {}
  chat_rooms   = {}
  Counter      = 0

  combinations_of_two = (num_of_clients) ->
    (num_of_clients * (num_of_clients - 1))/2

  get_users = ->
    users = []
    for key of online_users
      users.push key
      users

  io.configure( ->
    io.set 'authorization', (data, accept) ->
      if data.headers.cookie
        data.cookie       = cookie.parse data.headers.cookie
        data.sessionID    = data.cookie['express.sid'].substring(2, 26)
        data.sessionStore = store
        store.get data.sessionID, (err, session) ->
          if ( err || !session)
            return accept 'Invalid session', false
          data.session = session
      else
        return accept 'no cookie transmitted', false
      accept null, true
  )

  global_chat = io
    .on "connection", (socket)->
      return if !socket.handshake.session
      # Show a user who has come online
      socket.on "online", (data) ->
        socketID = socket.id
        io.sockets.emit "show_online_user",
          user: data.user
        online_users[data.user] = socketID unless online_users[data.user]?
      # Show user as offline when online user logs out
      socket.on "disconnect", ->
        user  = socket.handshake.session.currentUser.user_name
        io.sockets.emit "exit",
          user: user
        delete online_users[user]
      # Show a user's online users when he logs in
      io.sockets.emit "initial_online_users",
        users: get_users()

  i = 1
  while i <= 4
    chat = io
      .of("/room" + i )
      .on "connection", (socket) ->
        socket.on "chat", (data) ->
          user_init_conv  = socket.handshake.session.currentUser.user_name
          chatting_user   = data.user_to_chat
          chat.emit "message_log",
            message: data.message
            user_init_conv: user_init_conv
            chatting_user:  data.user_to_chat
    i++