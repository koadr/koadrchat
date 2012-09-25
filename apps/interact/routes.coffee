encrypt   = require("../pass").hash
salt_key  = null
hash_key  = null
check     = require('validator').check

routes = (app, mongoose, db) ->

  AllModels = require('../../models/all_models')(mongoose, db)
  Message   = AllModels.Message
  User      = AllModels.User

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

  app.get '/', (req, res) ->
    res.render "#{ __dirname}/views/homepage",
    title: 'Koadrchat'


  app.namespace '/users' , ->

    # List all users
    app.get '/', (req, res) ->
       User
        .find()
        .select('user_name email')
        .exec (err, all_users) ->
          res.render "#{ __dirname}/views/users/index",
            title: 'Koadrchat - Talk Away'
            all_users: all_users

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

    app.get '/users', (req, res) ->
      User
        .find()
        .select('user_name email')
        .exec (err, all_users) ->
          res.send(all_users)

  # # 404
  # app.get '*', (req, res) ->
  #   res.send('what???', 404)



module.exports = routes