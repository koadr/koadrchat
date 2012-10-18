class Interact.Views.ChatBox extends Backbone.View
  template: jade.templates["chat_box"]

  events:
    'keypress #chat_message': 'chat_message'

  initialize: (current_user, online_path, chat) ->
    @user         = current_user
    @online_path  = online_path
    @chat         = chat


  render: ->
    $(@el).html(@template(current_user: @user, online_users: @online_users, online_path: @online_path))
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
      @chat.emit 'setup_chat',
        user_to_chat: @user

      # $('#chat_message').val('')
      # $('#chat_message').val()