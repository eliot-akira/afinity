###---------------------------------------------
#
# Extended shortcuts for afinity object
#
# get, set, invalid, replace, child, children, load, create, register
#
###

# using $.isArray, each, extend
$ = require('jquery')

module.exports =

  get: ( arg ) -> @model.get arg

  set: ( arg, params, third ) -> @model.set arg, params, third

  silentSet: ( arg ) -> @model.set arg, silent:true

  reset: ( arg ) -> @model.reset arg

  invalid: -> @model.invalid()

  child: (n) ->
    i = 0
    n = n or 0
    for j of @_container.children
      if @_container.children.hasOwnProperty(j)
        if i == n
          return @_container.children[j]
        else if i > n
          return false
        i++
        # Continue searching
    false

  # { id: child, .. }
  children: -> @_container.children

  replace: (obj, selector) ->

    if typeof obj is 'string' and typeof selector is 'object'
      # switch args: selector, obj
      tmp = obj; obj = selector; selector = tmp

    if typeof selector is 'string' then @view.$(selector).html ''
    @empty()._container.append.apply @, arguments
    return @

  # Load models as children from the top
  load: (proto, models, selector) ->

    if typeof proto is 'string' and typeof selector is 'object'
      # switch args: selector, proto, models
      tmp = $.extend {}, models
      models = selector
      selector = proto
      proto = tmp

    maxModels = models.length
    maxChildren = @size()
    if !$.isArray(models)
      models = [ models ]
    $.each models, (index, model) =>
      if @child(index)
        @child(index).model.set model
      else

        # *** Need reference to afinity! ***

        @append afinity(proto, model), selector
      return

    # destroy the rest
    if maxChildren > maxModels
      i = maxModels
      while i < maxChildren
        # Child's index stays the same, since each one is destroyed
        @child(maxModels).destroy()
        i++
    return @
