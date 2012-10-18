class Interact.Views.ChatUsers extends Backbone.View
  template: jade.templates["chat_users"]
  className: "four columns end"

  events :
    'click .chat_row': 'open_chat_box'
    'click .toggle_chat_box': 'toggle_chat_box'

  initialize: (user, online_users) ->
    @user         = user
    @online_users = online_users
    @chat         = io.connect("http://localhost:3000/")
    @chat.on "connect", @notify_online, this
    @chat.on "initial_online_users", @show_initial_online_users, this
    @chat.on "show_online_user", @show_online_user , this
    @chat.on "exit", @disconnect_user, this
    @chat.on "client_connect", @chat_room_connect, this

  render: ->
    $(@el).html(@template(current_user: @user, online_users: @online_users))
    this

  notify_online: =>
    @chat.emit "online",
      user: @user

  show_initial_online_users: (data)=>
    for user in data.users
      @$("#" + user + " img:nth-of-type(2)").attr 'src', "/images/online_true.png"

  show_online_user: (data) =>
    @$("#" + data.user + " img:nth-of-type(2)").attr 'src', "/images/online_true.png"

  disconnect_user: (data) =>
    @$("#" + data.user + " img:nth-of-type(2)").attr 'src', "/images/online_false.png"

  toggle_chat_box: (event) ->
    @$(".chat-box").toggle()
    @$(".minimized-chat-box").toggle()

  user_chat_box_open: (event)->
    $users_chat       = $(".chat-box").find 'p'
    $users_chat_names = $users_chat.map (key, value)->
      value.textContent
    $user_chat_box    = @$(event.target).find 'li'
    $user_name        = $user_chat_box.html()
    return $.inArray($user_name, $users_chat_names)

  setup_chat_box: () ->
    new_cbox_placement = null
    $chat_box          = $(".chat-box")
    $chat_box_width    = $chat_box.width()
    $chat_box_pos      = $chat_box.css('right').replace("px", "")
    new_cbox_placement = Number($chat_box_pos) + $chat_box_width + 10
    if @chat_box_pos
      num_chat_boxes = $("#chat_rooms > div").length
      # Prevents the second chat_box from starting wrongfully in the third position.
      if num_chat_boxes > 2 then new_cbox_placement += @chat_box_pos else new_cbox_placement = @chat_box_pos
      # Prevents more chat boxes than two-thirds of the browser width
      return false if new_cbox_placement > (2.0/3 * $(window).width() )
      $("#chat_rooms > div:last-child .chat-box").css 'right', new_cbox_placement
    @chat_box_pos = new_cbox_placement

  setup_min_chat_box: () ->
    $chat_box          = $("#chat_rooms > div:last-child .chat-box")
    $chat_box_pos      = $chat_box.css('right').replace("px", "")
    $("#chat_rooms > div:last-child .minimized-chat-box").css 'right' , Number($chat_box_pos)

  open_chat_box: (event) ->
    $messaging_user    = @$(event.target).find('li')[0].textContent
    $online_url_path   = @$(event.target).find('.online_status')[0].src
    $chat_box_view     = new Interact.Views.ChatBox($messaging_user, $online_url_path, @chat)
    return if @user_chat_box_open(event) > -1
    $("#chat_rooms").append($chat_box_view.render().el)
    @setup_chat_box()
    @setup_min_chat_box()

  chat_room_connect: (data) ->
    connect_path = "#{data.connection_path}"
    for user in connect_path.split '-'
      $("#" + user).trigger 'click'
