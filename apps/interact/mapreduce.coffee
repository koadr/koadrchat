# Topics
# MapReduce for frequency of topics
yesterday = new Date()
yesterday.setDate(yesterday.getDate() - 1)
obj = {}
obj.map    = ->
  emit(this.name,1)
obj.reduce = (key, vals) ->
  sum = 0
  for index in vals
    sum += vals[index]
  return sum
obj.query  = {timestamp: {$gt: yesterday}}
obj.out = { replace: 'trends' }

exports.topics_obj = obj