class Interact.Views.ChatBox extends Backbone.View
  template: jade.templates["chat_box"]

  events :
    'click .toggle_chat_box': 'toggle_chat_box'
    'keypress #chat_message': 'chat_message'


  initialize: (intent_user, online_path) ->
    @user             = intent_user
    @online_path      = online_path

  render: ->
    $(@el).html(@template(current_user: @user, online_path: @online_path))
    this

  log_chat_message = (message, type) ->
    li = $("<li />").text(message)
    if type is "system"
      li.css "font-weight": "bold"
    else if type is "leave"
      li.css
        "font-weight": "bold"
        color: "#F00"

    @$("#chat_log").append li

  chat_message: (event)->
    if (event.which) == 13
      @chat.emit('chat',
        message: $('#chat_message').val()
      )
      $('#chat_message').val('')

  toggle_chat_box: (event) ->
    @$(".chat-box").toggle()
    @$(".minimized-chat-box").toggle()