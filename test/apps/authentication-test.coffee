require '../_helper'
require 'assert'
require('js-yaml')
express        = require 'express'
request        = require 'request'
assert         = require 'assert'
hash           = require("../../apps/pass").hash
app            = require "../../app.js"
expect         = require 'expect.js'
mongoose       = require 'mongoose'
test_config    = require("../../config/mongo.yml").test
db             = mongoose.createConnection(test_config.host, test_config.database , test_config.port)
AllModels      = require('../../models/all_models')(mongoose, db)
User           = AllModels.User
UserFactory    = require("../factories/user-factory.coffee")(mongoose, db)

inputs_for_login_form = ( user_name , pass) ->
  options =
    uri:"http://localhost:#{app.get('port')}/login"
    form:
      user: user_name
      password: pass
    followAllRedirects: false

inputs_for_register_form = (user_name , email , pass , pass_confirm ) ->
  options =
    uri:"http://localhost:#{app.get('port')}/register"
    form:
      user: user_name
      email: email
      password: pass
      password_confirmation: pass_confirm
    followAllRedirects: false

logout = ->
  options =
        uri:"http://localhost:#{app.get('port')}/logout"
        followAllRedirects: true


describe "authentication", ->
  before (done) ->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()

  describe "GET /login", ->
    body = null
    before (done) ->
      j = request.jar()
      request = request.defaults({jar:j})
      request {uri:"http://localhost:#{app.get('port')}/login"}, (err, response, _body) ->
        body = _body
        done()
    it "has title", ->
      assert.hasTag body, '//head/title', 'Login'
    it "has a user field", ->
      assert.hasTag body, '//input[@name="user"]', ''
    it "has a password field", ->
      assert.hasTag body, '//input[@name="password"]', ''

  describe "GET /register", ->
    body = null
    before (done) ->
      request {uri:"http://localhost:#{app.get('port')}/register"}, (err, response, _body) ->
        body = _body
        done()
    it "has title", ->
      assert.hasTag body, '//head/title', 'Register', ''
    it "has password", ->
      assert.hasTag body, '//input[@name="password"]', ''
    it "has password confirmation", ->
      assert.hasTag body, '//input[@name="password_confirmation"]', ''

  describe "POST /login", ->
    describe "incorrect credentials", ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save( { safe: true } )
        options = inputs_for_login_form 'incorrect user' , 'incorrect password'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "shows flash message for incorrect login", ->
        errorText = 'Username and password do not exist. Please ensure you have the right information.'
        assert.hasTag body, "//div[@class='flash error']", errorText

    describe "correct credentials", ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save( { safe: true } )
        options = inputs_for_login_form "#{user.user_name}" , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "registers user as online", (done) ->
        User.find (err, users) ->
          expect(users[0].online).to.be true
          done()
      it "shows flash message for correct login", ->
        flashText = "Welcome back #{user.user_name}!!!"
        assert.hasTag body, "//div[@class='flash info']", flashText
      it "redirects to homepage if user is already logged in", (done) ->
        request {uri:"http://localhost:#{app.get('port')}/login"}, (err, response, _body) ->
          body = _body
          errorText = 'You are already logged in. Log out first to log back in as a different user.'
          assert.hasTag body, "//div[@class='flash error']", errorText
          done()

  describe "POST /register", ->
    describe "correct credentials", ->
      [ body, response ] = [ null , null ]
      before (done) ->
        options = inputs_for_register_form 'foobar' , 'foobar@example.com' , '12345' , '12345'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "registers a user with the correct credentials", (done) ->
        User.find (err, users) ->
          expect(users[0].user_name).to.eql 'foobar'
          expect(users[0].email).to.eql 'foobar@example.com'
          done()
      it "shows flash message for new user", ->
        flashText = "Welcome to the Koadr Chatroom!!! You are now logged in as foobar"
        assert.hasTag body, "//div[@class='flash info']", flashText

    describe "correct credentials but duplicate username", ->
      [ body, response ] = [ null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save( { safe: true } )
        options = inputs_for_register_form 'Default_User28' , 'foobar@example.com' , '12345' , '12345'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "informs user if username is already taken" , ->
        errorText = "I'm sorry! That user name is already taken. Please try again."
        assert.hasTag body, "//div[@class='flash error']", errorText

    describe "incorrect password credentials", ->
      [ body, response ] = [ null , null ]
      before (done) ->
        options = inputs_for_register_form 'foobar' , 'example@example.com' , '12345' , '54321'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "returns with flash error if password and password_confirmation do not match", ->
        errorText = "Your passwords do not match. Please try again."
        assert.hasTag body, "//div[@class='flash error']", errorText
      it "does not register a user with non-matching passwords", (done) ->
        User.find (err, users) ->
          expect(users).to.be.empty()
          done()

    describe "incorrect email credentials", ->
      [ body, response ] = [ null , null ]
      before (done) ->
        options = inputs_for_register_form 'foobar' , '@example.com' , '12345' , '12345'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "returns with flash error if email is not valid", ->
        errorText = "Invalid Email!!!"
        assert.hasTag body, "//div[@class='flash error']", 'Invalid email!!!'
      it "does not register a user with incorrect email", (done) ->
        User.find (err, users) ->
          expect(users).to.be.empty()
          done()

  describe "DELETE /logout", ->
    [body, response,] = [null, null]
    before (done) ->
      user = UserFactory.build 'user'
      user.online = true
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          [body, response] = [_body, _response]
          done()
    it "shows the user as offline if an online user logs out", (done) ->
        request.del logout(), (err, _response, _body) ->
          [body, response] = [_body, _response]
          User.find (err, users) ->
            expect(users[0].online).not.to.be true
            done()
    it "shows flash message for logged out user", ->
      flashText = 'You have been logged out.'
      assert.hasTag body, "//div[@class='flash info']", flashText
    it "shows error message if user tries to logout despite already logged out" , (done) ->
      request.del logout(), (err, _response, _body) ->
        [body, response] = [_body, _response]
        errorText = "You are already not logged out."
        assert.hasTag body, "//div[@class='flash error']", errorText
        done()

  afterEach (done)->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()