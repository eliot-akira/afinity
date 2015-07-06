EventEmitter = require('events').EventEmitter

module.exports = ( obj ) ->
  obj = obj or {}
  ev = new Eventify
  # Extend object with eventify methods
  obj[key] = method for key, method of ev
  return obj

class Eventify

  constructor: -> @hub = new EventEmitter

  on : ( eventName, fn ) ->
    for event, handler of makeEventObj eventName, fn
      @hub.on event, handler
    return @

  once : ( eventName, fn ) ->
    for event, handler of makeEventObj eventName, fn
      @hub.once event, handler
    return @

  emit : ( eventName, data ) ->
    for event, eachData of makeEventObj eventName, data
      @hub.emit event, eachData
    return @

  trigger : ( eventName, data ) -> @emit eventName, data


makeEventObj = ( eventName, data ) ->
  allEvents = {}
  # Single event definition
  if typeof eventName is 'string' then allEvents[eventName] = data
  # Or multiple event definitions { event:fn, event:fn }
  else allEvents = eventName
  return allEvents
