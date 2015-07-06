###
#
# Extend base object with MVC from args
#
###

# Using: $.isEmpty, extend
$ = require 'jquery'
util = require '../util'
require '../util/jquery.util'

module.exports = ( object, args ) ->

  args = prepArgs args
  arg = args[0]

  # Prototype differential from { model, view, events } object
  for prop of arg
    switch prop

      # Model
      when 'model'
        $.extend object.model._data, arg.model

      # View
      when 'view'

        # { format, style }
        if typeof arg.view is 'object'
          $.extend object.view, arg.view
          continue

        # Direct template string
        if arg.view[0] isnt '#'
          object.view.format = arg.view
          continue

        # From DOM: '#template-id'
        $root = $(arg.view)
        viewTag = $root.prop('tagName')
        if typeof viewTag is 'undefined'
          throw new Error 'afinity: view template not found at ' + arg.view
        viewTag = viewTag.toLowerCase()

        # Template from script tag
        if viewTag == 'script' then object.view.format = $root.html()
        else
          # Template from existing DOM

          # If form, automatically bind inputs to model based on name
          if viewTag == 'form' then bindFormView $root, object

          # Include container itself
          object.view.format = $root.outerHTML()
          # Assign root to existing DOM element
          object.view.$root = $root
          object._template = true

      # Events
      when 'events', 'controller'
        $.extend object.controller, arg[prop]
        util.extendController object

      # User-defined methods
      else
        object[prop] = arg[prop]

  # For each property in object

  return object

prepArgs = ( args ) ->
  # if first argument is view template, pass args as { view:template }
  if typeof args[0] == 'string'
    argObj = {}
    argObj.view = args[0]
    if args.length > 1 and typeof args[1] == 'object'
      argObj.events = args[1]
    args = [ argObj ]
  return args

bindFormView = ( $root, object ) ->

  viewObj = {}
  required = {}

  $root.find('input, select, textarea').each ->

    $el = $(this)
    bind = $el.attr('data-bind')
    name = $el.attr('name')
    tag = $el.prop('tagName').toLowerCase()
    type = $el.attr('type') or ''
    req = $el.attr('required')

    if tag == 'textarea' then type = 'textarea'

    if $.isEmpty(bind) and !$.isEmpty(name)
      if type == 'checkbox' then viewObj[name] = $el.attr('checked') == 'checked'
        # boolean
      else if type == 'radio'
        # Radio is checked
        if $el.attr('checked') then viewObj[name] = $el.val()
        else
          # not checked
      else
        viewObj[name] = $el.val()

      $el.attr 'data-bind', name

    # If required, add it to array
    if typeof req != 'undefined'
      if type == 'email' or name == 'email' then required[name] = 'email'
      else required[name] = true
    return

  if !$.isEmpty(viewObj) then $.extend object.model._data, viewObj
  if !$.isEmpty(required) then object.required = $.extend(object.required or {}, required)
  return object
