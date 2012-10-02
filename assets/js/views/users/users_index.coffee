class Interact.Views.UsersIndex extends Backbone.View
  className: 'row'
  template: jade.templates["users_index"]

  events:
    'focus .share_message' : 'show_message_dropdown'

  initalize: ->

  render: ->
    $(@el).html(@template(users: @collection))
    this

  show_message_dropdown: (event) ->
    event.preventDefault()
    new_message_view = new Interact.Views.NewMessage()
    $('.share_message').html(new_message_view.render().el)
    $('div').removeClass('share_message')