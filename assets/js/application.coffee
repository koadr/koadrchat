#=require foundation.min
#=require underscore-min.js
#=require backbone-min.js
#=
#=require interact
#=require_tree ./templates
#=require_tree ./helpers
#=require_tree ./models
#=require_tree ./collections
#=require_tree ./views

jQuery ->

  log_chat_message = (message, type) ->
    li = jQuery("<li />").text(message)
    if type is "system"
      li.css "font-weight": "bold"
    else if type is "leave"
      li.css
        "font-weight": "bold"
        color: "#F00"

    jQuery("#chat_log").append li


  socket = io.connect "/"

  socket.on "entrance", (data) ->
    log_chat_message data.message, "system"

  socket.on "exit", (data) ->
    log_chat_message data.message, "leave"

  socket.on "chat", (data) ->
    log_chat_message data.message, "normal"

  jQuery("#chat_box").keypress (event) ->
    if event.which is 13
      socket.emit "chat",
        message: jQuery("#chat_box").val()

      jQuery("#chat_box").val ""