class Interact.Views.UsersIndex extends Backbone.View
  className: 'row'
  template: jade.templates["users_index"]

  events:
    'focus .message_box' : 'show_message_dropdown'

  initalize: ->

  render: ->
    $(@el).html(@template(users: @collection))
    this

  show_message_dropdown: (event) ->
    event.preventDefault()
    new_message_view = new Interact.Views.NewMessage()
    $('.message_box').remove()
    $('input').removeClass('.message_box')
    $('.new_message').append(new_message_view.render().el)
    $('.new_message').css('height', 215)
    $('.new_message textarea').focus()