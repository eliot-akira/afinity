###---------------------------------------------
#
# Shim for: Object.create and Object.getPrototypeOf
#
# forEach
#
###

# Using: $.extend
$ = require 'jquery'

# Modified from Douglas Crockford's Object.create()
# The condition below ensures we override other manual implementations
if !Object.create or Object.create.toString().search(/native code/i) < 0

  Object.create = (obj) ->
    Aux = ->
    $.extend Aux.prototype, obj
    # simply setting Aux.prototype = obj somehow messes with constructor, so getPrototypeOf wouldn't work in IE
    new Aux

# Modified from John Resig's Object.getPrototypeOf()
# The condition below ensures we override other manual implementations
if !Object.getPrototypeOf or Object.getPrototypeOf.toString().search(/native code/i) < 0
  if typeof 'test'.__proto__ is 'object'
    Object.getPrototypeOf = (object) ->
      object.__proto__
  else
    Object.getPrototypeOf = (object) ->
      # May break if the constructor has been tampered with
      object.constructor.prototype
