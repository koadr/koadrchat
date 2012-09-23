helpers = (app) ->
  app.dynamicHelpers =
    currentUser: (req, res) ->
      req.session.currentUser if req.session.currentUser





module.exports = helpers