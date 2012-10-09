FactoryYard = (mongoose, db) ->

  Message = require('../../models/all_models')(mongoose, db).Message

  @Factory.define('message', Message)
  .sequence('id')
  .attr('content', ->
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry.")

  @Factory

module.exports = FactoryYard