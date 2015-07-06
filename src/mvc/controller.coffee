###---------------------------------------------
#
# Controller
#
# Default controllers, i.e. event handlers. Event handlers that start
# with '_' are of internal use only, and take precedence over any other
# handler without that prefix. See: trigger()
#
###

# Using: $.remove
$ = require 'jquery'

module.exports =

  _create: ->
    @view.stylize() # Object style
    @view.bindings() # Model-view bindings
    @view.sync() # Sync view with model
    if @init? then @init() # shortcut to events:create
    return

  _destroy: ->
    # Remove generated style upon destruction of objects
    if @view.style
      $('head #afinity_'+ @_id, window.document).remove()
    # destroy any appended afinity objects
    @_container.empty()
    # destroy self in DOM, removing all events
    @view.$().remove()
    return

  _append: ( obj, selector ) ->
    @view.$(selector).append obj.view.$()
    return

  _prepend: ( obj, selector ) ->
    @view.$(selector).prepend obj.view.$()
    return

  _before: ( obj, selector ) ->
    @view.$(selector).before obj.view.$()
    return

  _after: ( obj, selector ) ->
    @view.$(selector).after obj.view.$()
    return

  _remove: ( id ) ->
    # Where is it defined..?

  _change: ->
