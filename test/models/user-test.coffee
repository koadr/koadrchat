require '../_helper'
require('js-yaml')
expect         = require 'expect.js'
mongoose       = require 'mongoose'
test_config    = require("../../config/mongo.yml").test
db             = mongoose.createConnection(test_config.host, test_config.database , test_config.port)
AllModels      = require('../../models/all_models')(mongoose, db)
Message        = AllModels.Message
User           = AllModels.User
Topic          = AllModels.Topic
UserFactory    = require("../factories/user-factory.coffee")(mongoose, db)
MessageFactory = require("../factories/message-factory.coffee")(mongoose, db)
TopicFactory = require("../factories/topic-factory.coffee")(mongoose, db)

describe 'User', ->

  before (done) ->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()

  describe "index", ->
    user_one = null
    user_two = null

    beforeEach (done) ->
      user_one = UserFactory.build('user')
      user_one.online = true
      user_two = UserFactory.build('user')
      user_one.save()
      user_two.save(done)
    it "should fetch all users", (done) ->
      User.find (errors, users) ->
        expect(users.length).to.be.eql 2
        done()
    it "should fetch all users currently online", (done) ->
      User.find_online_users (errors, users) ->
        expect(users.length).to.be.eql 1
        done()
    it "should fetch all users currently offline", (done) ->
      User.find_offline_users (err, users) ->
        expect(users.length).to.eql 1
        done()

  describe "create", ->
    user = null ; message = null

    beforeEach (done) ->
      user = UserFactory.build('user')
      done()

    it "sets user_name", (done) ->
      expect(user.user_name).not.to.be null
      done()
    it "should have a user_name field", ->
      expect(user).to.have.property "user_name"
    it "should have an email address field", ->
      expect(user).to.have.property "email"
    it "should have a salt field for encrypted password", ->
      expect(user).to.have.property "salt"
    it "should have an online state", ->
      expect(user).to.have.property "online"
    it "should have a hash field for encrypted password", ->
      expect(user).to.have.property 'hash'
    it "should have a date field", ->
      expect(user).to.have.property 'timestamp'
    it "should have a messages array property", ->
      expect(user).to.have.property 'messages'

  describe "update", ->
    user = null ; message = null

    beforeEach (done) ->
      user = UserFactory.build('user') ; message = MessageFactory.build 'message'
      user.messages.push message
      user.user_name = 'Koadr'
      user.messages[0].content = "Hello World!"
      user.save(done)

    it "should change state", ->
      expect(user.user_name).to.eql 'Koadr'
    it "should throw error when saving user_name that is less than 5 characters",  ->
      user.user_name = 'bad'
      user.save (errors, user) ->
        expect(errors).not.to.be null
    it "should throw error when saving unformatted email", ->
      bad_email = "12xs@$@me.com"
      user.email = bad_email
      user.save (errors, user) ->
        expect(errors).not.to.be null
    it "should throw error when saving salt if it is blank", (done)  ->
      user.salt = ''
      user.save (errors, user) ->
        expect(errors).not.to.be null
        done()
    it "should throw error when saving hash if it is blank", (done)  ->
      user.hash = ''
      user.save (errors, user) ->
        expect(errors).not.to.be null
        done()
    it "changes a message of a user", ->
      expect(user.messages[0].content).to.eql('Hello World!')
    it "associates a user with a message", (done) ->
      expect(user.messages).not.to.be.empty()
      done()
    it "saves a message with topic alongside a user" , ->
      topic = TopicFactory.build 'topic'
      message.topics.push topic
      message.save (err, msg) ->
        expect(user.messages).to.not.be undefined
        expect(user.messages[0].topics).to.not.be undefined
    it "populates topics for a message belonging to a user", (done) ->
      topic = TopicFactory.build 'topic'
      topic.save (err, topic) ->
        user.messages[0].topics.push topic
        message.save (err, message) ->
          Message.pop_topics_with_messages (err, msg) ->
            expect(msg[0].topics[0].name).to.eql topic.name
            done()
    afterEach (done) ->
      if db.collections['messages']
        db.collections['messages'].drop (err)->
          done()

  describe "show", ->
    user_one = null ; user_two = null; message_one = null ; message_two = null
    beforeEach (done) ->
      user_one = UserFactory.build('user') ; user_two = UserFactory.build('user')
      user_one.timestamp = new Date(1349500778330)
      user_two.timestamp = new Date(1349500778338)
      message_one = MessageFactory.build('message') ; message_two = MessageFactory.build('message')
      user_one.messages.push message_one ; user_one.messages.push message_two
      user_one.save()
      user_two.save()
      done()
    it "shows at most ten recent users ", (done) ->
      User.show_recent_users (err, users) ->
        expect(users[0].user_name).to.be.eql user_two.user_name
        done()
    it "should show all messages for a certain user", ->
      expect(user_one.messages.length).to.be.eql 2

  describe "destroy",  ->
    user_one = null ; user_two = null ; message = null
    options =
      safe: true

    before (done) ->
      user_one = UserFactory.build('user') ; user_two = UserFactory.build('user')
      message = MessageFactory.build 'message'
      user_one.messages.push message
      user_one.save()
      user_two.save(done)

    it "should delete a user", (done) ->
      user_two.remove (err, user) ->
        User.findById user_two._id , (err, user) ->
          expect(user).to.be null
        done()
    it "should allow a user to destroy a message", (done) ->
      user_one.messages.id(message._id).remove()
      expect(user_one.messages).to.be.empty()
      done()


  afterEach (done)->
    if db.collections['users']
      db.collections['users'].drop (err)->
        done()