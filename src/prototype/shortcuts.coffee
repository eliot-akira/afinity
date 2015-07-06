###---------------------------------------------
#
# Object shortcuts
#
###

module.exports =
  destroy: ->
    @trigger 'destroy', @_id
    # parent must listen to 'remove' event and handle container removal
    # can't return this as it might not exist anymore
    return
  parent: ->
    @_parent
  append: ->
    @_container.append.apply this, arguments
    return @
  prepend: ->
    @_container.prepend.apply this, arguments
    return @
  after: ->
    @_container.after.apply this, arguments
    return @
  before: ->
    @_container.before.apply this, arguments
    return @
  remove: ->
    @_container.remove.apply this, arguments
    return @
  size: ->
    @_container.size.apply this, arguments
  each: ->
    @_container.each.apply this, arguments
  empty: ->
    @_container.empty.apply this, arguments
  bind: ->
    @_events.bind.apply this, arguments
    return @
  on: ->
    @_events.bind.apply this, arguments
    return @
  trigger: ->
    @_events.trigger.apply this, arguments
    return @
