jQuery ->
  message_box_width = $('.new_message').width()
  $('.line_resize').css('width', message_box_width)

  $(window).resize ->
    message_box_width = $('.new_message').width()
    $('.line_resize').css('width', message_box_width)