User = (mongoose, db) ->

  Schema = mongoose.Schema

  MessageSchema = require("./message.coffee")(mongoose, db)

  UserSchema = new Schema
    user_name:
      type: String
      match: /^\w{5}(.*)$/
      required: true
      unique: true
    online:
      type: Boolean
      default: false
    salt:
      type: String
      required: true
    hash:
      type: String
      required: true
    email:
      type: String
      match: /^\s*[\w\-\+_]+(\.[\w\-\+_]+)*\@[\w\-\+_]+\.[\w\-\+_]+(\.[\w\-\+_]+)*\s*$/
    messages: [ MessageSchema ]

  UserSchema.statics.find_online_users = (callback) ->
    @find({online: true})
    .select('user_name online email messages')
    .exec(callback)

  UserSchema.statics.find_offline_users = (callback) ->
    @find({online: false})
    .select('user_name online email messages')
    .exec(callback)

  UserSchema

module.exports = User