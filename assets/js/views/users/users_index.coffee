class Interact.Views.UsersIndex extends Backbone.View
  className: 'eight columns'
  template: jade.templates["users_index"]

  events:
    'focus #message_box' : 'show_txt_msg_box'
    'click .share_msg_btn': 'add_message'
    'keyup #new_msg': 'char_countdown'

  initialize: (collection, user, helper, online_users) ->
    @collection      = collection
    @user            = user
    @helper          = helper
    @online_users    = online_users
    @collection.on 'change' , @render , this

  render: ->
    $(@el).html(@template(recent_users: @collection, current_user: @user, helper: @helper, online_users: @online_users))
    this

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