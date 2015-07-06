###
#
# util.*
#
# isAfinity
# size
# proxyAll
# extendController
#
###

# Using: $.proxy
$ = require 'jquery'
util = {}

# Checks if provided obj is an afinity object
util.isAfinity = (obj) ->
  if not obj? or typeof obj isnt 'object' then return false
  else return obj._afinity == true

# Determines # of attributes of given object (prototype inclusive)
util.size = (obj) ->
  size = 0
  for key of obj
    size++
  return size

# Scans object for functions (depth=2) and proxies their 'this' to dest.
# * To ensure it works with previously proxied objects, we save the original function as
#   a '._preProxy' method and when available always use that as the proxy source.
# * To skip a given method, create a sub-method called '_noProxy'.

util.proxyAll = ( obj, dest ) ->

  if !obj or !dest
    throw new Error 'afinity.js: util.proxyAll needs two arguments'

  for attr1 of obj
    proxied = obj[attr1]
    # Proxy root methods
    if typeof obj[attr1] == 'function'
      proxied = if obj[attr1]._noProxy then obj[attr1] else $.proxy(obj[attr1]._preProxy or obj[attr1], dest)
      proxied._preProxy = if obj[attr1]._noProxy then undefined else obj[attr1]._preProxy or obj[attr1]
      # save original
      obj[attr1] = proxied
    else if typeof obj[attr1] == 'object'
      # don't proxy jQuery or afinity object
      if obj[attr1] instanceof jQuery or util.isAfinity obj[attr1]
        continue
      for attr2 of obj[attr1]
        proxied2 = obj[attr1][attr2]
        if typeof obj[attr1][attr2] == 'function'
          proxied2 = if obj[attr1][attr2]._noProxy then obj[attr1][attr2] else $.proxy(obj[attr1][attr2]._preProxy or obj[attr1][attr2], dest)
          proxied2._preProxy = if obj[attr1][attr2]._noProxy then undefined else obj[attr1][attr2]._preProxy or obj[attr1][attr2]
          # save original
          proxied[attr2] = proxied2
      # for attr2
      obj[attr1] = proxied
    # if not func
  # for attr1
  return

# Find controllers to be extended (with syntax '~'),
# redefine those to encompass previously defined controllers
# Example:
#   var a = $$({}, '<button>A</button>', {'click &': function(){ alert('A'); }});
#   var b = $$(a, {}, '<button>B</button>', {'~click &': function(){ alert('B'); }});
# Clicking on button B will alert both 'A' and 'B'.

util.extendController = (object) ->
  for controllerName of object.controller
    # new scope as we need one new function handler per controller
    do ->
      if typeof object.controller[controllerName] == 'function'
        matches = controllerName.match(/^(\~)*(.+)/)
        # 'click button', '~click button', '_create', etc
        extend = matches[1]
        eventName = matches[2]
        # nothing to do
        if !extend then return

        # Redefine controller:
        # '~click button' ---> 'click button' = previousHandler + currentHandler
        previousHandler = if object.controller[eventName] then object.controller[eventName]._preProxy or object.controller[eventName] else undefined
        currentHandler = object.controller[controllerName]

        newHandler = ->
          if previousHandler
            previousHandler.apply this, arguments
          if currentHandler
            currentHandler.apply this, arguments
          return

        object.controller[eventName] = newHandler
        # delete '~click button'
        delete object.controller[controllerName]
      # if function
      return
  # for controllerName
  return

module.exports = util
