###
#
# Create base object
#
###

# Shim for Object.methods
# TODO: Consider deprecating
require('../base/shim')

# Using jQuery for $.extend and DOM methods for view
# TODO: Consider Zepto+lodash
$ = require 'jquery'

idCounter = 0

module.exports = ( prototype ) ->

  # Build object from prototype as well as the individual prototype parts
  # Enables differential inheritance at the sub-object level, e.g. object.view.format

  object = Object.create(prototype)
  object.model = Object.create(prototype.model)
  object.view = Object.create(prototype.view)
  object.controller = Object.create(prototype.controller)
  object._container = Object.create(prototype._container)
  object._events = Object.create(prototype._events)
  object.form = Object.create(prototype.form)

  # Instance properties, i.e. not inherited
  object._id = idCounter++
  object._parent = null
  object._events.data = {}

  # event bindings will happen below
  object._container.children = {}

  if prototype.view.$root instanceof jQuery and prototype._template
    # prototype $root template exists: clone its content
    object.view.$root = $(prototype.view.$root.outerHTML())
  else
    object.view.$root = $()
    # empty jQuery object

  # Clone own properties
  # i.e. properties that are inherited by direct copy instead of prototype chain.
  # This prevents children from altering parents models

  # Children
  object._data = {}
  if prototype._data
    $.extend(true, object._data, prototype._data)

  # Model
  object.model._data = {}
  if prototype.model._data
    $.extend(true, object.model._data, prototype.model._data)

  return object
