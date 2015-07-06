###
#
# _events API and auxiliary functions for handling events
#
###

# Using: $.data, find, on, trigger
$ = require('jquery')

# Also in mvc/view.js
ROOT_SELECTOR = '&'

###
#
# Parse event string
#
# 'event'          : custom event
# 'event selector' : DOM event using 'selector'
#
# Returns { type:'event' [, selector:'selector'] }
#
###

parseEventStr = (eventStr) ->
  eventObj = type: eventStr
  spacePos = eventStr.search(/\s/)
  # DOM event 'event selector', e.g. 'click button'
  if spacePos > -1
    eventObj.type = eventStr.substr(0, spacePos)
    eventObj.selector = eventStr.substr(spacePos + 1)
  else if eventStr in ['click', 'submit', 'keyup', 'keydown']
    # @extend Shortcut for 'click &', 'submit &', etc.
    eventObj.type = eventStr
    eventObj.selector = ROOT_SELECTOR
  return eventObj

# Reverses the order of events attached to an object

reverseEvents = (obj, eventType) ->
  events = $(obj).data('events')
  if events != undefined and events[eventType] != undefined
    # can't reverse what's not there
    reversedEvents = []
    for e of events[eventType]
      if !events[eventType].hasOwnProperty(e)
        continue
      reversedEvents.unshift events[eventType][e]
    events[eventType] = reversedEvents
  return

module.exports =

  bind: ( eventStr, fn ) ->

    eventObj = parseEventStr(eventStr)

    # Prevent default & bubbling for click and submit
    fnx = (event) ->
      fn event
      return false
      # or just prevent default? if ( ! event.isDefaultPrevented() ) event.preventDefault();

    # DOM event 'event selector', e.g. 'click button'
    if eventObj.selector

      # Keep click and submit contained
      if eventObj.type is 'click' or eventObj.type is 'submit'
        # Override root selector, as jQuery selectors can't select self object
        if eventObj.selector is ROOT_SELECTOR
          @view.$().on eventObj.type, fnx
        else @view.$().on eventObj.type, eventObj.selector, fnx
      else
        if eventObj.selector is ROOT_SELECTOR
          @view.$().on eventObj.type, fn
        else @view.$().on eventObj.type, eventObj.selector, fn
    else
      # Object event
      # TODO: Use eventify instead of jQuery

      # $(@_events.data).on eventObj.type, fn
      # Callback gets only data: skip jQuery event object in the first argument
      $(@_events.data).on eventObj.type, (ev, data...) -> return fn data...

    return @

  trigger: ( eventStr, params, internal = true ) ->

    eventObj = parseEventStr(eventStr)

    # DOM event 'event selector', e.g. 'click button'
    if eventObj.selector

      # Override root selector, as jQuery selectors can't select self object
      if eventObj.selector == ROOT_SELECTOR
        @view.$().trigger eventObj.type, params
      else
        @view.$().find(eventObj.selector).trigger eventObj.type, params

    else
      # Object event
      # TODO: Use eventify instead of jQuery

      if internal then $(@_events.data).trigger '_' + eventObj.type, params

      # fire 'pre' hooks in reverse attachment order ( last first ) then put them back
      reverseEvents @_events.data, 'pre:' + eventObj.type
      $(@_events.data).trigger 'pre:' + eventObj.type, params
      reverseEvents @_events.data, 'pre:' + eventObj.type

      $(@_events.data).trigger eventObj.type, params

      # Trigger event for parent
      if @parent()
        if eventObj.type.match(/^child:/) then prefix = ''
        else prefix = 'child:'
        @parent().trigger prefix+eventObj.type, params

      $(@_events.data).trigger 'post:' + eventObj.type, params

    return @
