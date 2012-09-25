class Interact.Views.UsersIndex extends Backbone.View

  tagName: "li"

  initalize: ->

  template: jade.templates["users_index"]()

  render: ->
    $(@el).html(@template)
    this