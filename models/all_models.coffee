models = (mongoose, db) ->
  MessageSchema  = require('./message')(mongoose, db)
  UserSchema = require('./user')(mongoose, db)

  User = db.model 'User', UserSchema
  Message = db.model 'Message', MessageSchema

  { Message: Message, User: User }

module.exports = models