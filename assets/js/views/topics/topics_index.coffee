class Interact.Views.TopicsIndex extends Backbone.View
  tagName: 'div'
  attributes: {class: 'four columns'}
  template: jade.templates["topics_index"]

  initialize: (collection, helper) ->
    @collection = collection
    @helper     = helper

  render: ->
    $(@el).html(@template(trending_topics: @collection, helper: @helper))
    this