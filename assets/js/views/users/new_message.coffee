class Interact.Views.NewMessage extends Backbone.View

  tagName: "form"

  initalize: ->

  template: jade.templates["new_message_form"]

  render: ->
    $(@el).html(@template())
    this