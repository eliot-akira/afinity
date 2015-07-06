###---------------------------------------------
#
# Construct default object prototype
#
###

# Using: $.extend
$ = require('jquery')

defaultPrototype =
  _afinity: true
  _container: require('./container')
  _events: require('./events')
  $node: {}
  key: {}
  required: {}
  model: require('../mvc/model')
  view: require('../mvc/view')
  controller: require('../mvc/controller')

shortcuts = require('./shortcuts')
extend = require('./extend')
form = require('./form')

module.exports = $.extend(defaultPrototype, shortcuts, extend, form)
