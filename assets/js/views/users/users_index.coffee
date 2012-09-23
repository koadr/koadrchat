class Interact.Views.UsersIndex extends Backbone.View

  tagName: "li"

  initalize: ->

  template: JST["users/index"]()

  render: ->
    $(@el).html(@template)
    this