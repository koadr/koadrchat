class Interact.Views.ChatBox extends Backbone.View
  template: jade.templates["chat_box"]

  events:
    'keypress #chat_message': 'chat_message'

  initialize: (user_to_chat, user, online_path, chat, room1, room2, room3, room4) ->
    @contacting_user       = user_to_chat
    @current_user          = user
    @online_path           = online_path
    @chat                  = chat
    @chat_rooms            = {}
    @room1                 = room1
    @room2                 = room2
    @room3                 = room3
    @room4                 = room4
    @Counter               = 0

  is_user_online: ->
    regex = /true/
    online = regex.test @online_path

  render: ->
    $(@el).html(@template(messaging_user: @contacting_user, online_users: @online_users, online_path: @online_path, user_online: @is_user_online()))
    this

  gen_chat_room: (u1 , u2) ->
    # Only 4 chat rooms can be functional at one time.
    rooms = ["room1", "room2", "room3", "room4"]
    if @chat_rooms["#{u1}-#{u2}"]?
      return @chat_rooms["#{u1}-#{u2}"]
    @chat_rooms["#{u1}-#{u2}"] = @chat_rooms["#{u2}-#{u1}"] = rooms[@Counter]
    if Counter == 3 then Counter = 0 else Counter++
    @chat_rooms["#{u1}-#{u2}"]

  chat_attrs =
    user_to_chat: @contacting_user
    message: $('#chat_message').val()

  chat_message: (event) ->
    if (event.which) == 13
      switch @gen_chat_room @current_user , @contacting_user
        when "room1"
          @room1.emit "chat",
            user_to_chat: @contacting_user
            message: $('#chat_message').val()
        when "room2"
          @room2.emit "chat",
            user_to_chat: @contacting_user
            message: $('#chat_message').val()
        when "room3"
          @room3.emit "chat",
            user_to_chat: @contacting_user
            message: $('#chat_message').val()
        when "room4"
          @room4.emit "chat",
            user_to_chat: @contacting_user
            message: $('#chat_message').val()
      message: $('#chat_message').val('')