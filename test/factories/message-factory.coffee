FactoryYard = (mongoose, db) ->

  Message = require('../../models/all_models')(mongoose, db).Message

  @Factory.define('message', Message)
  .sequence('id')
  .attr('content', ->
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.")

  @Factory

module.exports = FactoryYard