###---------------------------------------------
#
# Model API
#
# get
# set
# reset
# size
# each
#
# invalid
# isValid
# isValidKey
#
###

# Using: $.each, $.extend and $.proxy
$ = require 'jquery'
util = require '../util'
modelValidate = require './model-validate'

model =

  get: require './model-get'

  set: require './model-set'

  reset: ( obj ) ->
    if not obj then obj = @model._initData
    @model.set obj, reset: true
    return @

  size: ->
    util.size @model._data

  each: (fn) ->
    # Proxy this object
    $.each @model._data, $.proxy fn, @
    return @

module.exports = $.extend model, modelValidate
