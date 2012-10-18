module.exports = (app, server, mongoose, db, store) ->

  cookie           = require("cookie")
  AllModels       = require('../models/all_models')(mongoose, db)
  User            = AllModels.User

  io        = require('socket.io').listen(server)
  online_users = []

  combinations_of_two = (num_of_clients) ->
    (num_of_clients * (num_of_clients - 1))/2

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

  chat = io
    .on("connection", (socket)->
      return if !socket.handshake.session
      socket.on "online", (data) ->
        io.sockets.emit "show_online_user",
          user: data.user
          online_users.push data.user unless online_users.indexOf(data.user) != -1
      socket.on "disconnect", ->
        user  = socket.handshake.session.currentUser.user_name
        io.sockets.emit "exit",
          user: user
        index = online_users.indexOf(user)
        online_users.splice index, 1
      io.sockets.emit "initial_online_users",
        users: online_users
    )

  # User.find (err, users) ->
  #   for user in users
  #     num_chat_rooms = combinations users.length

  #     chat = io
  #       .of("/chat-#{user.user_name}")
  #       .on("connection", (socket) ->
  #         socket.emit "entrance",
  #           message: "#{user.user_name} is online"
  #         socket.on('disconnect', ->
  #           socket.emit "exit",
  #             message: "#{user.user_name} is offline"
  #         )
  #         socket.on('chat', (data) ->
  #           chat.emit "chat",
  #             message: "#{data.message}"
  #         )
  #       )
