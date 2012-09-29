encrypt  = require("../pass").hash
salt_key = null
hash_key = null
check    = require('validator').check

routes = (app, mongoose, db) =>

  AllModels = require('../../models/all_models')(mongoose, db)
  Message   = AllModels.Message
  User      = AllModels.User

  get_session_name = (req)->
    if req.session.currentUser?
      req.session.currentUser.user_name
    else
      null


  authenticate = (name, pass, fn) ->
    User.find { user_name: name }, null , (err, user_search) ->
      user = user_search[0]

      return fn(new Error("Username and password do not exist. Please ensure you have the right information."))  unless user

      encrypt pass, user.salt, (err, hash) ->
        return fn(err)  if err
        hash = Buffer(hash, 'binary').toString('base64')
        return fn(null, user)  if hash is user.hash
        fn new Error("Invalid username and password")

  check_email = (req , res , next) ->
    try
      check(req.body.email).isEmail()
    catch error
      req.flash 'error' , error.message + '!!!'
      return res.redirect '/register'
    next()

  check_for_dup_username = (req, res, next) ->
    name = req.body.user
    User.find { user_name: name } , (err, user_search) ->
      if user_search[0]
         req.flash 'error' , "I'm sorry! That user name is already taken. Please try again."
         return res.redirect '/register'
      next()

  encrypt_password = (req, res, next) ->

    password                = req.body.password
    password_confirmation   = req.body.password_confirmation

    if password != password_confirmation
      req.flash 'error' , "Your passwords do not match. Please try again."
      return res.redirect '/register'

    encrypt password , (err, salt, hash) ->
      throw err if err
      salt_key = salt
      hash_key = Buffer(hash, 'binary').toString('base64')
      next()

  auth_user = (req, res, next) ->
    user_name = req.body.user
    password  = req.body.password

    authenticate user_name , password , (error, user) ->
      if user
        user.online = true
        user.save()
        req.session.regenerate ->
          req.session.currentUser = user
          next()
      else
        req.flash 'error' , error.message
        return res.redirect '/login'

  app.get '/login', (req, res) ->
    if req.session.currentUser
      req.flash 'error', 'You are already logged in. Log out first to log back in as a different user.'
      return res.redirect '/'
    res.render "#{ __dirname}/views/login",
      title: "Login"

  app.post '/login', auth_user , (req, res) ->
    req.flash 'info' , "Welcome back #{req.session.currentUser.user_name}!!!"
    res.redirect '/'

  app.get '/register', (req, res) ->
    res.render "#{ __dirname}/views/register",
      title: "Register"

  app.post '/register', check_email , check_for_dup_username , encrypt_password, (req, res) ->
    attributes =
      user_name: req.body.user
      email: req.body.email
      salt: salt_key
      hash: hash_key
    user = new User attributes
    user.online = true
    user.save (err, user) ->
      req.session.currentUser = user
      req.flash 'info' , "Welcome to the Koadr Chatroom!!! You are now logged in as #{req.session.currentUser.user_name}"
      res.redirect '/'

  app.del '/logout' , (req, res) ->
    session_user_name = get_session_name req
    if !session_user_name?
      req.flash 'error' , "You are already not logged out."
      return res.redirect '/'
    User.find { user_name: session_user_name } , (err, users) ->
      if user = users[0]
        user.online = false
        user.save (err, user) ->
          req.session.regenerate (err) ->
            req.flash 'info' , 'You have been logged out.'
            res.redirect '/login'
      return

module.exports = routes