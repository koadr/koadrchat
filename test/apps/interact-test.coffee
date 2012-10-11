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
Topic          = AllModels.Topic
UserFactory    = require("../factories/user-factory.coffee")(mongoose, db)
MessageFactory = require("../factories/message-factory.coffee")(mongoose, db)
TopicFactory = require("../factories/topic-factory.coffee")(mongoose, db)


inputs_for_login_form = (user_name , pass) ->
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
    followAllRedirects: false

logout = ->
  options =
    uri:"http://localhost:#{app.get('port')}/logout"
    followAllRedirects: true

create = (content = 'foo' , user_name) ->
  options =
        uri: "http:" + "//localhost:#{app.get('port')}/api/users/"
        body:
          user_name: user_name
          messages: [{content: content, topic_names:[
            "Foo"]}]
        json: true

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
        options = inputs_for_login_form "#{user.user_name}" , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            [body, response] = [_body, _response]
            done()
      # it "update states for user when user is logged in", (done) ->
      #   update_options = inputs_for_update_form 'foofi@foo.com', '123456' , '123456' , user.user_name
      #   hash           = 'RcJX1gmkUbQm8JWVHy+aEBfTC/iTCFY8+CGkoy5r8L/mV/MybAKPRX7heoSNF4+/a4Gv50sQmzwrB8qtB4srScxk91rb3X05VlpEvQ2FoOBUHTVHIHTp5SIagqSQs6Cps4cvdw73RzTHPu+DL41iGCvHdr0JpGwicPDx85WLtoI='
      #   request.put update_options, (upErr, upPostResponse, upPostResponseBody) ->
      #     request.get "http:" + upPostResponse.headers.location, (err, _response, _body) ->
      #       User.findById user._id , (err, user) ->
      #         expect(user.email).to.eql 'foofi@foo.com'
      #         expect(user.hash).to.not.eql hash
      #         done()


  describe 'GET /users/:id/', ->
    describe 'NOT logged in' , ->
      [ body, response, user ] = [ null , null , null ]
      before (done) ->
        user = UserFactory.build 'user'
        user.save()
        j = request.jar()
        request = request.defaults({jar: j})
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
        options = inputs_for_login_form "#{user.user_name}" , 'foobar'
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
        options = inputs_for_login_form "#{user.user_name}" , 'foobar'
        request.post options, (ignoreErr, postResponse, postResponseBody) ->
          request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
            done()
      it "goes to edit page", (done) ->
         request {uri:"http://localhost:#{app.get('port')}/users/#{user.user_name}/edit"}, (err, _response, _body) ->
          expect(_response.request.uri.path).to.eql "/users/#{user.user_name}/edit"
          done()

  describe 'api/GET /users' , ->
    user  = null ; body = null
    before (done) ->
      user = UserFactory.build 'user'
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "returns json data" , (done) ->
      request "http://localhost:#{app.get('port')}/api/users", (err, _response, _body) ->
        content_type = (_response.headers['content-type'].split ';')[0]
        body = _body
        expect(content_type).to.eql 'application/json'
        done()
    it "should show all users" , ->
      expect(body).to.contain user.user_name

  describe 'api/GET /users/:id' , ->
    user  = null ; body = null
    before (done) ->
      user = UserFactory.build 'user'
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "returns json data" , (done) ->
      request "http://localhost:#{app.get('port')}/api/users/#{user.user_name}", (err, _response, _body) ->
        content_type = (_response.headers['content-type'].split ';')[0]
        body = _body
        expect(content_type).to.eql 'application/json'
        done()
    it "should show user" , ->
      expect(body).to.contain user.user_name

  describe 'api/PUT /users/:id' , ->
    [ body, response, user ] = [ null , null , null ]
    before (done) ->
      user = UserFactory.build 'user'
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "should not return with 404" , (done) ->
      update_options     = inputs_for_update_form 'foofi@foo.com', '123456' , '123456' , user.user_name
      update_options.uri =  "http://localhost:#{app.get('port')}/api/users/#{user.user_name}"
      request.put update_options , (err, _response, _body) ->
        response = _response
        expect(response.statusCode).not.to.be 404
        done()
    it "should update"
    it "should return updated state in json"

  describe 'api/POST /users' , ->
    [ body, response, user, second_user ] = [ null , null , null , null]
    beforeEach (done) ->
      user = UserFactory.build 'user'
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "should not return with 404", (done) ->
      opts = create 'No 404!' , user.user_name
      request.post opts , (err, _response, _body) ->
        response = _response
        expect(response.statusCode).not.to.be 404
        done()
    it "should create message for user", (done) ->
      opts = create 'Hey World!' , user.user_name
      request.post opts , (err, _response, _body) ->
        User.find { user_name: user.user_name } , (err, user) ->
          expect(user[0].messages[0].content).to.be.eql("Hey World!")
          expect(err).to.be null
          done()
    it "should update user's timestamp after creating a message for user" , (done) ->
      timestamp = user.timestamp.toString()
      opts = create 'Update My Timestamp!' , user.user_name
      request.post opts , (err, _response, _body) ->
        User.find { user_name: user.user_name } , (err, user) ->
          expect(user[0].timestamp.toString()).not.to.equal(timestamp)
          expect(err).to.be null
          done()

  describe 'GET api/topics' , ->
    topic  = null ; body = null ; user = null;
    before (done) ->
      topic = TopicFactory.build 'topic'
      user  = UserFactory.build 'user'
      topic.save()
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "returns json data" , (done) ->
      request "http://localhost:#{app.get('port')}/api/topics", (err, _response, _body) ->
        content_type = (_response.headers['content-type'].split ';')[0]
        body = _body
        expect(content_type).to.eql 'application/json'
        done()
    it "should show all topics" , ->
      expect(body).to.contain topic.name

  describe 'api/GET /topics/:id' , ->
    user  = null ; body = null ; topic = null
    before (done) ->
      user  = UserFactory.build 'user'
      topic = TopicFactory.build 'topic'
      user.save()
      topic.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "returns json data" , (done) ->
      request "http://localhost:#{app.get('port')}/api/topics/#{topic._id}", (err, _response, _body) ->
        content_type = (_response.headers['content-type'].split ';')[0]
        body = _body
        expect(content_type).to.eql 'application/json'
        done()
    it "should show topic" , ->
      expect(body).to.contain topic._id

  describe 'api/PUT /topics/:id' , ->
    [ body, response, user , topic ] = [ null , null , null , null ]
    before (done) ->
      user  = UserFactory.build 'user'
      topic = TopicFactory.build 'topic'
      topic.save()
      user.save()
      options = inputs_for_login_form "#{user.user_name}" , 'foobar'
      request.post options, (ignoreErr, postResponse, postResponseBody) ->
        request.get "http:" + postResponse.headers.location, (err, _response, _body) ->
          done()
    it "should not return with 404" , (done) ->
      # update_options = inputs_for_update_topic_form 'Animals', user.user_name
      request.put "http:" + "//localhost:#{app.get('port')}/api/topics/#{topic._id}", (err, _response, _body) ->
        response = _response
        expect(response.statusCode).not.to.be 404
        done()

  describe '404', ->
    [ body, response, user ] = [ null , null , null ]
    before (done) ->
      user = UserFactory.build 'user'
      user.save()
      request {uri:"http://localhost:#{app.get('port')}/users/badlink/edit/"}, (err, _response, _body) ->
        [body, response] = [_body, _response]
        done()
    it "should respond with 404 for bad uri", ->
      expect(response.statusCode).to.eql '404'


  afterEach (done)->
    if db.collections['users']
      db.collections['users'].drop (err)->
        if db.collections['topics']
          db.collections['topics'].drop (err)->
            done()