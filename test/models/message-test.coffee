require '../_helper'
require('js-yaml')
expect         = require 'expect.js'
mongoose       = require 'mongoose'
test_config    = require("../../config/mongo.yml").test
db             = mongoose.createConnection(test_config.host, test_config.database , test_config.port)
AllModels      = require('../../models/all_models')(mongoose, db)
Message        = AllModels.Message
MessageFactory = require("../factories/message-factory.coffee")(mongoose, db)


describe "Message", ->

  before (done) ->
    if db.collections['messages']
      db.collections['messages'].drop (err)->
        done()

  describe "create", ->
    message = null

    beforeEach (done) ->
      message = MessageFactory.build('message')
      done()

    it "has a content property", ->
      expect(message).to.have.property('content')

    it "associated with topics", ->
      expect(message).to.have.property('topics')

    it "has a timestamp property", ->
      expect(message).to.have.property 'timestamp'

    it "sets message", ->
      expect(message.length).not.to.be.eql 0

  describe "update", ->
    message = null

    beforeEach (done) ->
      message = MessageFactory.build('message')
      message.content = 'Lorem Ipsum'
      message.save(done)

    it "should change state", ->
      expect(message.content).to.eql('Lorem Ipsum')

    it "does not allow to you to write a message longer than 150 characters", (done) ->
      message.content = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam."
      message.save (err, msg) ->
        expect(err).to.not.be null
        done()

  describe "index", ->
    message_one = null ; message_two = null

    before (done) ->
      message_one = MessageFactory.build('message')
      message_two = MessageFactory.build('message')
      message_one.save()
      message_two.save(done)

    it "should fetch all messages", (done)  ->
      Message.find (errors, messages) ->
        expect(messages.length).to.be.eql 2
        done()

  describe "destroy", ->
    message = null

    options =
      safe: true

    before (done) ->
      message = MessageFactory.build('message')
      message.save(done)

    beforeEach (done) ->
      Message.findByIdAndRemove(message._id, options, done)

    it "should delete a message", (done) ->
      Message.find (err, messages) ->
        expect(messages).to.be.empty()
        done()

  afterEach (done) ->
    if db.collections['messages']
      db.collections['messages'].drop (err)->
        done()