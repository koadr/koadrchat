FactoryYard  = (mongoose, db) ->
  User       = require('../../models/all_models')(mongoose, db).User
  salt       = 'PuOGWIQQSR+4ZCqyGljv32t9pNlOMMp7Si1Nhx+QJHjAVnePai3NNg03iTJR0r7htjIcwMsmIGFua/SIJSWGJr9NGl2HcTWM0uAPw4UD0T2jh9pcY//bNSwR8gwhExi58KVX6qkX9R9PkJ/nuaRt+W9+AQET+m41g12fKcwXYI4='
  hash       = 'RcJX1gmkUbQm8JWVHy+aEBfTC/iTCFY8+CGkoy5r8L/mV/MybAKPRX7heoSNF4+/a4Gv50sQmzwrB8qtB4srScxk91rb3X05VlpEvQ2FoOBUHTVHIHTp5SIagqSQs6Cps4cvdw73RzTHPu+DL41iGCvHdr0JpGwicPDx85WLtoI='

  @Factory.define('user', User)
  .sequence('id')
  .sequence('user_name', (i)->
    'Default_User' + i )
  .attr('salt',
    salt)
  .attr('hash',
    hash)

  @Factory

module.exports = FactoryYard