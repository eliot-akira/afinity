###---------------------------------------------
#
# Get
#
###

# Using: $.isPlainObject
$ = require 'jquery'

module.exports = ( arg ) ->

  # get() returns the whole model
  if not arg then return @model._data

  # Get attribute
  # @pull #91 Add support for nested models: parent.child
  if typeof arg == 'string'
    paths = arg.split('.')
    value = @model._data[paths[0]]
    #check for nested objects
    if $.isPlainObject(value)
      i = 1
      while i < paths.length
        if $.isPlainObject(value) and value[paths[i]]
          value = value[paths[i]]
        else
          value = value[paths.splice(i).join('.')]
        i++
    else
      #direct key access
      value = @model._data[arg]
    return value

  throw new Error 'afinity: unknown argument for get'
  return
