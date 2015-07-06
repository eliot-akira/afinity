###
#
# Set: set model attributes and trigger change events
#
# TODO: Break it down into small functions
# TODO: Optimize performance by removing extraneous operations
#
###

# Using: $.extend, $.isPlainObject
$ = require('jquery')

module.exports = ( arg, params, third ) ->

  # list of modified model attributes
  modified = []
  previous = {}

  # Set individual model property: model.set( prop, value )
  if typeof arg is 'string'
    attr = arg
    arg = {}
    if typeof params is 'object' then arg[attr] = $.extend {}, params
    else arg[attr] = params
    params = third or {}

  if typeof arg is not 'object'
    throw new Error 'afinity.js: unknown argument type in model.set()'

  if params and params.reset
    # hold on to original data for change events
    _clone = $.extend {}, @model._data
    # erase previous model attributes without pointing to object
    @model._data = $.extend {}, arg

  else

    # hold on to original data for change events
    _clone = $.extend {}, @model._data

    for prop of arg

      if prop.indexOf('.') < 0 then break
      path = prop.split('.')
      current_node = @model._data[ path[0] ] or {}

      # @pull #91 Add support for nested models
      # Iterate through properties and find nested declarations
      i = 1
      while i < path.length - 1
        next_node = current_node[path[i]]
        if $.isPlainObject(next_node) then current_node = next_node
        else
          current_node[path[i]] = {}
          current_node = current_node[path[i]]
        i++

      last_property = path[path.length - 1]
      if $.isPlainObject(arg[key]) and $.isPlainObject(current_node[last_property])
        #if we're assigning objects, extend rather than replace
        $.extend current_node[last_property], arg[prop]
      else current_node[last_property] = arg[prop]

    $.extend @model._data, arg

  # Given object
  for key of arg
    # Check if changed
    if @model._data[key] isnt _clone[key]
      modified.push key
      previous[key] = _clone[key]
    delete _clone[key]

  # Previous object
  for key of _clone
    # Check if changed
    if @model._data[key] isnt _clone[key]
      modified.push key
      previous[key] = _clone[key]

  # Done..

  # Do not fire events
  if params and params.silent then return @

  # Trigger change events
  # @extend Pass array of modified model keys
  # $().trigger parses the second parameter as separate arguments,
  # so we put it in an array
  @trigger 'change', [ modified, previous ]

  if params and params.direct then internal = false
  else interal = true

  for key, index in modified
    @trigger 'change:' + key, previous[key], internal

  return @
