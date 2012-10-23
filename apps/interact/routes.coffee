encrypt    = require("../pass").hash
salt_key   = null
hash_key   = null
check      = require('validator').check
obj        = require("./mapreduce.coffee").topics_obj
# chat_rooms = require("../socket-io.coffee")
# console.log chat_rooms

routes = (app, mongoose, db) ->

  AllModels = require('../../models/all_models')(mongoose, db)
  Message   = AllModels.Message
  User      = AllModels.User
  Topic     = AllModels.Topic

  add_render_users = (res, recent_users, topics = '')->
    User
      .find()
      .select('user_name online')
      .exec (err, online_users) ->
        res.render "#{ __dirname}/views/users/index",
          title: 'Koadrchat - Talk Away'
          recent_users: recent_users
          online_users: online_users
          topics: topics

  save_new_user_info = (req, res, user, topic = '')->
    user.messages      = req.body.messages
    user.timestamp     = new Date()
    last_message_attrs = user.messages[req.body.messages.length - 1]
    message            = new Message last_message_attrs
    if topic != ''
      message.topics.push topic unless message.topics[topic._id]
    message.save (err, msgs) ->
      user.save (err, usr) ->
        res.json user

  get_session_name = (req)->
    if req.session.currentUser?
      req.session.currentUser.user_name
    else
      null

  check_email = (req , res , next) ->
    try
      check(req.body.email).isEmail()
    catch error
      req.flash 'error' , error.message + '!!!'
      return res.redirect "/users/#{req.params.id}/edit"
    next()

  encrypt_password = (req, res, next) ->

    password                = req.body.password
    password_confirmation   = req.body.password_confirmation

    if password != password_confirmation
      req.flash 'error' , "Your passwords do not match. Please try again."
      return res.redirect 'back'

    encrypt password , (err, salt, hash) ->
      throw err if err
      salt_key = salt
      hash_key = Buffer(hash, 'binary').toString('base64')
      next()

  authenticate = (req,res,next) ->
    session_user_name = get_session_name req
    if !req.session.currentUser?
      req.flash 'error' , "Please login!"
      return res.redirect '/login'
    next()

  app.get '/', (req, res) ->
    res.render "#{ __dirname}/views/homepage",
    title: 'Koadrchat'

  app.namespace '/users' , ->

    # List all users
    app.get '/', authenticate, (req, res) ->
      User.show_recent_users (err, recent_users) ->
        Topic.mapReduce obj, (err, topic, stats) ->
          if topic
            topic.find().limit(5).sort('-value').exec (err, topics) ->
              add_render_users res, recent_users, topics
          else
            add_render_users res, recent_users


    # Edit User
    app.get '/:id/edit' , (req, res) ->
      User.find { user_name: req.params.id } , (err, user_arr) ->
        user = user_arr[0]
        return res.send('what???', 404) if not user
        session_user_name = get_session_name req
        if not (user.user_name == session_user_name)
          req.flash 'error' , "Please login as user to change credentials!"
          return res.redirect '/'
        res.render "#{ __dirname}/views/users/edit",
          title: 'Koadrchat - Edit'
          user: user


    # Update User
    app.put '/:id' , check_email , encrypt_password ,  (req, res) ->
      User.find { user_name: req.params.id } , (err, user_arr) ->
        user = user_arr[0]
        return res.send('what???', 404) if not user
        session_user_name = get_session_name req
        if not (user.user_name == session_user_name)
          req.flash 'error' , "Please login as user to change credentials!"
          return res.redirect '/'
        user.email = req.body.email
        user.hash  = hash_key
        user.salt  = salt_key
        user.save (err, user) ->
        req.flash 'info' , "Your credentials have been updated"
        res.redirect "/users"

    # Show User
    app.get '/:id', (req, res) ->
      User.find { user_name: req.params.id } , (err, user_arr) ->
        user = user_arr[0]
        return res.send('what???', 404) if not user
        if not req.session.currentUser
          req.flash 'error' , "Please login"
          return res.redirect '/'
        res.render "#{ __dirname}/views/users/show",
          title: 'Koadrchat - Talk Away'
          user: user

  app.namespace '/api' , ->

    app.all '*' , authenticate

    app.get '/users', (req, res) ->
      User.show_recent_users (err, recent_users) ->
        User
          .find()
          .select('user_name online')
          .exec (err, online_users) ->
            res.json({recent_users:recent_users, online_users: online_users})

    app.post '/users', (req, res) ->
      User.find { user_name: req.session.currentUser.user_name } , (err, usr_arr) ->
        user            = usr_arr[0]
        message = req.body.messages[req.body.messages.length - 1]
        if !(req.body.user_name == user.user_name)
          req.flash 'error', 'Please do not try to alter the content of other users.'
          return res.redirect "/users/#{user.user_name}"
        if message.topic_names?
          for topic_name in message.topic_names
            topic                = new Topic
            topic.name           = topic_name
            topic.timestamp      = new Date()
            topic.save (err, topic) ->
              save_new_user_info req, res, user, topic
        else
          save_new_user_info req, res, user

    app.get '/users/:id' ,(req, res) ->
       User
        .find({ user_name: req.params.id })
        .select('user_name online email messages')
        .exec (err, user_arr) ->
          user = user_arr[0]
          res.json user

    app.put '/users/:id' , (req, res) ->
      User.find { user_name : req.params.id } , (err, user_arr) ->
        user = user_arr[0]
        user.save (err, user) ->
          res.json user

    # Topics
    app.get '/topics' , (req, res) ->
      Topic.mapReduce obj, (err, topic, stats) ->
        topic.find().limit(5).sort('-value').exec (err, topics) ->
          res.json topics

    app.post 'topics' , (req, res) ->

    app.get 'topics/:id' , (req, res) ->
      Topic
        .findById req.params.id , (err, topic) ->
          res.json topic

    app.put '/topics/:id' , (req, res) ->
      Topic.findById req.params.id , (err, topic) ->
        topic.save (err, topic) ->
          res.json topic



  # # 404
  # app.get '*', (req, res) ->
  #   res.send('what???', 404)



module.exports = routes