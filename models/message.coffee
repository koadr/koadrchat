Message = (mongoose, db) ->

  Schema = mongoose.Schema

  MessageSchema = new Schema
    content:
      type: String

  MessageSchema

module.exports = Message