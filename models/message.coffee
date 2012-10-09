Message = (mongoose, db) ->

  Schema = mongoose.Schema

  string_validator = (str) ->
    return str.length < 150

  MessageSchema = new Schema
    content:
      type: String
      validate: [string_validator , 'Too many characters']
      required: true
    topics:[
      type: Schema.ObjectId
      ref: 'Topic'
    ]
    timestamp:
      type: Date
      default: Date.now()

  MessageSchema.statics.pop_topics_with_messages = (callback) ->
    @find()
    .select('topics')
    .populate('topics','name')
    .exec(callback)

  MessageSchema

module.exports = Message