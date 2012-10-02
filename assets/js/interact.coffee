window.Interact =
  Models: {}
  Collections: {}
  Views: {}
  Helper: {}
  init: ->
    @collection = new Interact.Collections.Users()
    @collection.reset($('#bootstrapped_users').data('messages'))
    users_page = new Interact.Views.UsersIndex(collection: @collection)
    $("#user_enter").html(users_page.render().el)


$(document).ready ->
  Interact.init()