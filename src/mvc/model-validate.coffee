###---------------------------------------------
#
# Validate model properties based on object.required
#
###

# Using: $.isEmpty and $.isEmail
$ = require 'jquery'
$util = require('../util/jquery.util')

module.exports =

  invalid: ->
    invalid = []
    # Check each required key
    for key of @required
      if !@model.isValidKey(key)
        invalid.push key
    return invalid

  isValid: (key) ->
    if typeof key == 'undefined'
      # Check the whole model
      return @model.invalid().length is 0
    else
      return @model.isValidKey key

  isValidKey: (key) ->
    if typeof @required[key] is 'undefined'
      return true
    val = @model.get(key)
    requireType = @required[key]
    if requireType is true
      return !$.isEmpty(val)
    else if requireType is 'email'
      return $.isEmail(val)
    else
      # Other types of required: boolean, checked, custom condition..?
    return true
    # Passed all requirements
