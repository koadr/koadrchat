models = (mongoose, db) ->
  MessageSchema  = require('./message')(mongoose, db)
  UserSchema     = require('./user')(mongoose, db)
  TopicSchema    = require('./topic')(mongoose, db)

  User    = db.model 'User', UserSchema
  Message = db.model 'Message', MessageSchema
  Topic   = db.model 'Topic', TopicSchema

  { Message: Message, User: User, Topic: Topic }

module.exports = models