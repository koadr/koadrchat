class Interact.Views.UsersIndex extends Backbone.View
  className: 'row'
  template: jade.templates["users_index"]

  events:
    'focus #message_box' : 'show_txt_msg_box'
    'click .share_msg_btn': 'add_message'
    'keyup #new_msg': 'char_countdown'
    'click .chat_row': 'open_chat_box'

  initialize: (collection, user, helper, online_users) ->
    @collection      = collection
    @user            = user
    @helper          = helper
    @online_users    = online_users
    @collection.on 'change' , @render , this
    @chat            = io.connect("http://localhost:3000/")
    @chat.on "connect", @notify_online, this
    @chat.on "initial_online_users", @show_initial_online_users, this
    @chat.on "show_online_user", @show_online_user , this
    @chat.on "exit", @disconnect_user, this

  render: ->
    $(@el).html(@template(recent_users: @collection, current_user: @user, helper: @helper, online_users: @online_users))
    this

  log_chat_message = (message, type) ->
    li = $("<li />").text(message)
    if type is "system"
      li.css "font-weight": "bold"
    else if type is "leave"
      li.css
        "font-weight": "bold"
        color: "#F00"

    $("#chat_log").append li

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

  show_txt_msg_box: (event) ->
    event.preventDefault()
    $('#message_box').remove()
    $('.new_message').css('height', 215)
    $('#new_msg_text_box').toggle().focus()

  add_message: (event) ->
    event.preventDefault()
    $content    = @$('#new_msg').val()
    regex       = /#\w+/gi
    input       = $content
    topic_names = null
    if regex.test input
      topic_names = input.match regex
    new_message =
      content: $content
      topic_names: topic_names
    user = @collection.filter((model) =>
      model.get('user_name') is @user
    )[0]
    messages = user.get('messages')
    messages.push new_message
    user.save() if $content.length > 0 && !($content.length > 150)

  char_countdown: (event) ->
    $content    = @$('#new_msg').val()
    $share_btn  = @$('.share_msg_btn')
    if $content.length > 0 && $content.length <= 150
      $share_btn.removeClass("secondary tiny")
      $share_btn.addClass("medium")
    else if ($content.length == 0) || ($content.length > 150)
      $share_btn.removeClass("medium")
      $share_btn.addClass("secondary tiny")

    char_remaining = (150 - $content.length)

    if char_remaining < 15
      $('.char_count').html "<span class='red'>#{char_remaining}</span>"
    else
      $('.char_count').html "<span class='blue'>#{char_remaining}</span>"

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
    $chat_box_view     = new Interact.Views.ChatBox($messaging_user, $online_url_path)
    return if @user_chat_box_open(event) > -1
    $("#chat_rooms").append($chat_box_view.render().el)
    @setup_chat_box()
    @setup_min_chat_box()

