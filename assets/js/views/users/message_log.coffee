class Interact.Views.MessageLog extends Backbone.View
  template: jade.templates["message_log"]

  className: "message_log"

  initialize: (user, message, user_init_conv)->
    @current_user   = user
    @message        = message
    @user_init_conv = user_init_conv


  format_time: ()->
    ap   = "AM"
    time = new Date()
    if (min = time.getMinutes()) < 10 then min = '0' + min else min
    ap = "PM" if time.getHours() > 12
    hr   = Math.abs(12 - time.getHours())
    hr+":"+min+ap

  render: ->
    $(@el).html(@template(current_user: @current_user, time:@format_time(), message: @message, user_init_conv: @user_init_conv))
    this