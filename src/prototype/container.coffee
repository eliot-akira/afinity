###---------------------------------------------
#
# _container
#
# API and related auxiliary functions for storing child Afinity objects.
# Not all methods are exposed. See 'shortcuts' below for exposed methods.
#
###

# Using: $.each
$ = require('jquery')
util = require('../util')

module.exports =

  _insertObject: ( obj, selector, method, args ) ->

    if typeof obj is 'string'
      # switch args: selector, obj, method
      tmp = obj; obj = selector; selector = tmp
    else if typeof obj is 'object' and typeof selector is 'object'
      # no selector, just a list of objects
      args ?= []
      args.unshift selector # push at beginning of array
      selector = ''

    if not util.isAfinity(obj)
      throw new Error 'afinity.js: append argument is not an afinity object'

    # children is object with id hash
    @_container.children[obj._id] = obj
    @trigger method, [ obj, selector ]
    obj._parent = @

    # ensures object is removed from container when destroyed:
    obj.bind 'destroy', ( id ) =>
      @_container.remove id
      # Return empty
      return

    # Trigger event for child to listen to
    obj.trigger 'parent:' + method

    # Do the same for a list of obj in args
    if args? then @[method] arg, selector for arg in args

    return @

  append: (obj, selector, args...) ->
    @_container._insertObject.call @, obj, selector, 'append', args
  prepend: (obj, selector, args...) ->
    @_container._insertObject.call @, obj, selector, 'prepend'
  after: (obj, selector, args...) ->
    @_container._insertObject.call @, obj, selector, 'after'
  before: (obj, selector, args...) ->
    @_container._insertObject.call @, obj, selector, 'before'
  remove: (id) ->
    delete @_container.children[id]
    @trigger 'remove', id
    return @
  each: (fn) ->
    $.each @_container.children, fn
    return @
  empty: ->
    @each -> @destroy()
    return @
  size: ->
    return util.size @_container.children
