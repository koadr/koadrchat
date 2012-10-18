window.Interact =
  Models: {}
  Collections: {}
  Views: {}
  Helper: {}
  init: ->
    @user              = $('#user_name').data('user')
    @online_users      = $('#bootstrapped_online_users').data('online_users')
    @users_collection  = new Interact.Collections.Users()
    @user_helper       = new Interact.Helper.User(@user, @user_messages, @users_collection)
    @topic_helper      = new Interact.Helper.Topic(@topics_collection)
    @users_collection.reset($('#bootstrapped_recent_users').data('recent_users'))
    @topics_collection = new Interact.Collections.Topics()
    @topics_collection.reset($('#bootstrapped_topics').data('topics'))
    users_messages     = new Interact.Views.UsersIndex(@users_collection, @user, @user_helper, @online_users)
    topics_sect        = new Interact.Views.TopicsIndex(@topics_collection, @topic_helper)
    chat_sect          = new Interact.Views.ChatUsers(@user, @online_users)
    $("#user_show").html(users_messages.render().el)
    $("#trending_topics").html(topics_sect.render().el)
    $("#chat_app").html(chat_sect.render().el)

$(document).ready ->
  regex = /users(\/)?([a-zA-Z]+(\/)?)?$/
  if regex.test location.pathname
    Interact.init()