###
#
# Launch sequence: Bindings, initializations, etc
#
###

# Using $.extend and $.each
$ = require('jquery')
util = require('../util')

module.exports = ( object ) ->

  # Save model's initial state (so it can be .reset() later)
  object.model._initData = $.extend {}, object.model._data

  # object.* will have their 'this' === object.
  # This must come before call to object.* below.
  util.proxyAll object, object

  # Initialize $root, needed for DOM events binding below
  object.view.render()

  bindEvent = (ev, handler) ->
    if typeof handler == 'function'
      object.bind ev, handler
    return

  # Bind all controllers to their events
  for eventStr of object.controller
    events = eventStr.split(',')
    # Changed from ';'
    handler = object.controller[eventStr]
    $.each events, (i, ev) ->
      ev = $.trim(ev)
      bindEvent ev, handler
      return

  object.trigger 'create'

  return object
