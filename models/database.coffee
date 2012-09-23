db = (mongoose, config) ->

  switch process.env.NODE_ENV
    when "development"
      mongoose.createConnection(config.development.host, config.development.database , config.development.port)
    when "test"
      mongoose.createConnection(config.test.host, config.test.database , config.test.port)
    when "production"
      mongoose.createConnection(config.production.host, config.production.database , config.production.port)
    else
      throw new Error("Could not connect to database")

module.exports = db