###
#
# Root afinity methods
#
# isAfinity
# body
# create, clone, use
# eventify
# html, css, escaped
#
###

# Using: jQuery object
$ = require 'jquery'
util = require '../util'
# Event emitter factory
eventify = require '../extend/eventify'
# Template helpers
html = require '../extend/html'
css = require '../extend/css'
escaped = require '../extend/escaped'

module.exports = ( afinity ) ->

  # isAfinity test
  afinity.isAfinity = (obj) ->
    if typeof obj != 'object' then return false
    util.isAfinity obj

  # afinity.body is a unique afinity object, whose view is attached to <body>
  # This object can be used as the main entry point for all DOM operations
  afinity.body = afinity(
    _body: true
    view:
      $: (selector) -> if selector then $(selector, 'body') else $('body')
    # bypass default create event
    controller: _create: ->
  )

  ###
  #
  # create, clone, use
  #
  # Simple module system to register a prototype and create instances
  #
  ###

  registeredModules = {}

  afinity.create = (name, obj) ->

    # template given as string
    if typeof name is 'string' and name[0] in ['<', '#']
      return afinity name, obj

    # { model, view, events }
    if typeof name is 'object'
      # { name, model, view, events }
      if name.name? then return afinity.create name.name, name
      # afinity object with no name
      else return afinity name, obj

    if typeof obj is 'object'
      # Register an existing afinity object
      if util.isAfinity obj then registeredModules[name] = obj
      # Or create a new one
      else registeredModules[name] = afinity obj
      return registeredModules[name]

  afinity.clone = (name, obj) ->
    if util.isAfinity name then afinity name, obj
    else if registeredModules[name]? then return afinity registeredModules[name], obj
    else throw new Error 'afinity.clone: module ' + name + ' not found'

  afinity.use = (name) ->
    if registeredModules[name]? then return registeredModules[name]
    else throw new Error 'afinity.use: module ' + name + ' not found'

  # Event manager factory
  afinity.eventify = eventify
  afinity.eventify afinity # Eventify yoself

  # Template helpers
  afinity.html = html
  afinity.css = css
  afinity.escaped = escaped

  return afinity
