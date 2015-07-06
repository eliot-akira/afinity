###
#
# jQuery utility functions
#
# outerHTML, isEmpty, isEmail, serializeObject
#
# TODO: Make these internal - don't attach on $
#
###

$ = require('jquery')

# Get element including wrapping tag
$.fn.outerHTML = (s) ->
  if s
    @before(s).remove()
  else
    doc = if @[0] then @[0].ownerDocument else document
    jQuery('<div>', doc).append(@eq(0).clone()).html()

# Generic isEmpty

$.isEmpty = (mixed_var) ->
  # Empty: null, undefined, '', [], {}
  # Not empty: 0, true, false
  undef = undefined
  key = undefined
  i = undefined
  len = undefined
  emptyValues = [
    undef
    null
    ''
  ]
  i = 0
  len = emptyValues.length
  while i < len
    if mixed_var is emptyValues[i] then return true
    i++

  if typeof mixed_var is 'object'
    for key of mixed_var
      if mixed_var.hasOwnProperty(key) then return false
    return true

  return false

# Validate e-mail

$.isEmail = (email) ->
  if $.isEmpty(email)
    return false
  regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/
  regex.test email

# Serialize form

$.fn.serializeObject = ->
  data = {}
  active =
    datepicker: typeof $.pikaday != 'undefined'
    timepicker: typeof $.timepicker != 'undefined'

  @find('input, select, textarea').each ->
    $el = $(this)
    type = $el.attr('type')
    name = $el.attr('name')
    val = $el.val()
    if name?
      # Checkbox: if multiple, create array of values
      if type is 'checkbox'
        if !$el.prop('checked') then val = ''
        # Create an array of checkbox values
        if typeof data[name] == 'undefined' then data[name] = val
        else
          # Single one a string
          if typeof data[name] == 'string' then data[name] = [ data[name] ]
          # Put first element in an array
          data[name].push val
      else
        # Datepicker
        if active.datepicker and $el.hasClass('datepicker') then val = $el.pikaday('getDate')
        # Timepicker -> appended select element
        else if active.timepicker and $el.hasClass('timepicker') then val = $el.next().val()
        data[name] = val
    return
  # End: each field

  return data
