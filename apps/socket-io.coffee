module.exports = (app, server, mongoose, db, store) ->

  cookie           = require("cookie")
  AllModels       = require('../models/all_models')(mongoose, db)
  User            = AllModels.User

  io        = require('socket.io').listen(server)

  online_users = {}

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
    .on("connection", (socket)->
      return if !socket.handshake.session
      socket.on "online", (data) ->
        socketID = socket.id
        io.sockets.emit "show_online_user",
          user: data.user
        online_users[data.user] = socketID unless online_users[data.user]?

      socket.on "disconnect", ->
        user  = socket.handshake.session.currentUser.user_name
        io.sockets.emit "exit",
          user: user
        delete online_users[user]

      io.sockets.emit "initial_online_users",
        users: get_users()

      socket.on "setup_chat", (data) ->
        main_user       = socket.handshake.session.currentUser.user_name
        user_to_chat    = data.user_to_chat
        users_socketIDS = [online_users[main_user], online_users[user_to_chat]]
        for socketID in users_socketIDS
          io.sockets.socket(socketID).emit "client_connect",
            connection_path: "#{main_user}-#{user_to_chat}"
        # chat = io.
        #   .of("/#{main_user_user_to_chat}")
        #   .on("connection", (socket) ->
        #     chat.emit "client_connect",
        #       connection_path: "/#{main_user_user_to_chat}"
        #   )
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
