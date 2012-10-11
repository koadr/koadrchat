class Interact.Views.ChatBox extends Backbone.View
  template: jade.templates["chat_box"]

  events :
    'click .toggle_chat_box': 'toggle_chat_box'


  initialize: (user, online_path) ->
    @user        = user
    @online_path = online_path

  render: ->
    $(@el).html(@template(current_user: @user, online_path: @online_path))
    this

  toggle_chat_box: (event) ->
    @$(".chat-box").toggle()
    $(".minimized-chat-box").toggle()