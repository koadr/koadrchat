Topic = (mongoose, db) ->

  Schema = mongoose.Schema

  TopicSchema = new Schema
    name:
      type: String
      required: true
    timestamp:
      type: Date
      default: Date.now()

  TopicSchema

module.exports = Topic