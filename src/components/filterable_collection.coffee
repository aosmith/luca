Luca.components.FilterableCollection = Backbone.Collection.extend
  url: ()->

  initialize: (models, options={})->
    _.extend @, options
    Backbone.Collection.prototype.initialize.apply @, arguments

  applyFilter: (@params={})->