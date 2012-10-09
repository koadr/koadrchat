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
    users_page         = new Interact.Views.UsersIndex(@users_collection, @user, @user_helper, @online_users)
    topics_page        = new Interact.Views.TopicsIndex(@topics_collection, @topic_helper)
    $("#user_enter").html(users_page.render().el)
    $("#trending_topics").html(topics_page.render().el)

$(document).ready ->
  Interact.init()