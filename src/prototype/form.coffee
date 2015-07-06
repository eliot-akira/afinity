###---------------------------------------------
#
# Form helpers
#
###

# Using: DOM methods - attr, val, find
$ = require('jquery')

require '../util/jquery.util'

module.exports = form:

  clear: ->

    checkedRadio = []

    # Clear all inputs
    @$view.find(':input, textarea')
      .not(':button, :submit, :reset, :hidden')
      .removeAttr('checked')
      .removeAttr('selected')
      .not(':checkbox, :radio, select')
      .val ''

    # Check first radio of group
    @$view.find(':radio').each (i, el) =>
      $el = $(el)
      name = $el.attr('name')
      val = $el.val()
      if checkedRadio.indexOf(name) < 0
        checkedRadio.push name
        $el.attr 'checked', 'checked'
        # Set model property
        @set name, val
      return

    return @$view

  invalid: -> @model.invalid()

  toObject: -> @$view.serializeObject()

  toJSON: ->
    obj = @$view.serializeObject()
    return JSON.stringify obj
