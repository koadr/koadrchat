class Interact.Helper.User
  constructor: (user, messages, collection) ->
    @user = user
    @collection = collection

  simpleFormat: (str) ->
    str = str.replace(/\r\n?/, "\n")
    str = $.trim(str)
    if str.length > 0
      str = str.replace(/\n\n+/g, "</p><p>")
      str = str.replace(/\n/g, "<br />")
      str = "<p>" + str + "</p>"
    str


  get_recent_msg: (user)->
    if user.get('messages').length == 0
      ""
    else
      messages = user.get('messages')
      messages[messages.length - 1].content