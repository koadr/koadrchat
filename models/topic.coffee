Topic = (mongoose, db) ->

  Schema = mongoose.Schema

  TopicSchema = new Schema
    name:
      type: String
      required: true
    timestamp:
      type: Date
      default: Date.now()

  TopicSchema.statics.trending_topics = (callback) ->
    @find()
    .sort('-timestamp')
    .limit(5)
    .exec(callback)

  TopicSchema

module.exports = Topic