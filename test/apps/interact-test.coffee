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

inputs_for_update_form = (email, pass, pass_conf , username ) ->
  options =
    uri: "http://localhost:#{app.get('port')}/users/#{username}"
    form:
      email: email
      password: pass
      password_confirmation: pass_conf

logout = ->
  options =
    uri:"http://localhost:#{app.get('port')}/logout"
    followAllRedirects: true

describe 'interact' , ->
  before (done) ->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()

  describe 'GET /', ->
    body = null
    before (done) ->
      request {uri:"http://localhost:#{app.get('port')}/"}, (err, response, _body) ->
        body = _body
        done()
    it "has title", ->
      assert.hasTag body, '//title', "Koadrchat"

  describe 'GET /users', ->
    body = null
    user_one = null ; user_two = null
    before (done) ->
      user_one = UserFactory.build 'user'
      user_one.save()
      request {uri:"http://localhost:#{app.get('port')}/users"}, (err, response, _body) ->
        throw new Error(_body) if response.statusCode != 200
        body = _body
        done()
    it "displays title on page", ->
      assert.hasTag body, '//head/title', 'Koadrchat - Talk Away'

  describe 'PUT /users/:id' , ->
    describe 'NOT logged in' , ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        update_options = inputs_for_update_form 'foofi@foo.com', '123456' , '123456' , user.user_name
        request.put update_options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "does not update states for user when user is not logged in" , ->
        User.find user._id , (err, user) ->
          expect(user.email).not.to.eql 'foofi@foo.com'
          expect(user.hash).not.to.eql 'RcJX1gmkUbQm8JWVHy+aEBfTC/iTCFY8+CGkoy5r8L/mV/MybAKPRX7heoSNF4+/a4Gv50sQmzwrB8qtB4srScxk91rb3X05VlpEvQ2FoOBUHTVHIHTp5SIagqSQs6Cps4cvdw73RzTHPu+DL41iGCvHdr0JpGwicPDx85WLtoI='
      it "redirects back to homepage", ->
        expect(response.request.uri.path).to.eql '/'
      it "prompts the user that he is not logged in", ->
        errorText = 'Please login as user to change credentials!'
        assert.hasTag body, "//div[@class='flash error']", errorText

    describe "logged in", ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        options = inputs_for_login_form 'Default_User31' , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "update states for user when user is logged in", (done) ->
        update_options = inputs_for_update_form 'foofi@foo.com', '123456' , '123456' , user.user_name
        hash           = hash       = 'RcJX1gmkUbQm8JWVHy+aEBfTC/iTCFY8+CGkoy5r8L/mV/MybAKPRX7heoSNF4+/a4Gv50sQmzwrB8qtB4srScxk91rb3X05VlpEvQ2FoOBUHTVHIHTp5SIagqSQs6Cps4cvdw73RzTHPu+DL41iGCvHdr0JpGwicPDx85WLtoI='
        request.put update_options, (upErr, upPostResponse, upPostResponseBody) ->
          request.get "http:" + upPostResponse.headers.location, (err, _response, _body) ->
            User.findById user._id , (err, user) ->
              expect(user.email).to.eql 'foofi@foo.com'
              expect(user.hash).to.not.eql hash
              done()


  describe 'GET /users/:id/', ->
    describe 'NOT logged in' , ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        request.del logout(), (ignoreErr, delResponse, delResponsebody) ->
          request {uri:"http://localhost:#{app.get('port')}/users/#{user.user_name}"}, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      it "should redirect to home page if not logged in" , ->
        expect(response.request.uri.path).to.eql '/'
      it "should prompt user to login", ->
        errorText = "Please login"
        assert.hasTag body, "//div[@class='flash error']", errorText
    describe 'logged in', ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        options = inputs_for_login_form 'Default_User33' , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            done()
      it "goes to user page", (done) ->
         request {uri:"http://localhost:#{app.get('port')}/users/#{user.user_name}"}, (err, _response, _body) ->
          expect(_response.request.uri.path).to.eql "/users/#{user.user_name}"
          done()

  describe 'GET /users/:id/edit' , ->
    describe 'NOT logged in' , ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        request {uri:"http://localhost:#{app.get('port')}/users/#{user.user_name}/edit"}, (err, _response, _body) ->
          [body, response] = [_body, _response]
          done()
      it "should redirect to home page if not logged in as the user whose credentials you want to edit", ->
        expect(response.request.uri.path).to.eql '/'
      it "should prompt user that not logged in", ->
        errorText = 'Please login as user to change credentials!'
        assert.hasTag body, "//div[@class='flash error']", errorText
    describe "logged in" , ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        options = inputs_for_login_form 'Default_User35' , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            done()
      it "goes to edit page", (done) ->
         request {uri:"http://localhost:#{app.get('port')}/users/#{user.user_name}/edit"}, (err, _response, _body) ->
          expect(_response.request.uri.path).to.eql "/users/#{user.user_name}/edit"
          done()

  describe '404', ->
    [ body, response, user ] = [ null , null , null ]
    before (done) ->
      user = UserFactory.build 'user'
      user.save()
      request {uri:"http://localhost:#{app.get('port')}/users/badlink/edit"}, (err, _response, _body) ->
        [body, response] = [_body, _response]
        done()
    it "should respond with 404 for bad uri", ->
      expect(response.statusCode).to.eql '404'


  afterEach (done)->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()