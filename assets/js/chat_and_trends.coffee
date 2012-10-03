jQuery ->

  $(window).scroll ->
    scrolled_pixels = $(this).scrollTop()
    if scrolled_pixels >= 123
      $('.chatroom').css('position', 'fixed')
      $('.chatroom').css('top', '0')
      $('.trending_box').css('position', 'fixed')
      $('.trending_box').css('top', '0')
    else
      $('.chatroom').css('position', 'static')
      $('.trending_box').css('position', 'static')