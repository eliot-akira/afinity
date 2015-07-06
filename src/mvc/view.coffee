###---------------------------------------------
#
# View API
#
# view.format
# view.style
# view.$
# render
# bindings
# sync
# stylize
# $bound
#
###

# Using: jQuery object, html, addClass, size, append
$ = require 'jquery'
viewBind = require('./view-bind')

# Also in prototype/events.js
ROOT_SELECTOR = '&'

module.exports =

  format: '<div/>'

  style: ''

  $: (selector) ->
    if !selector or selector == ROOT_SELECTOR
      return @view.$root
    else
      @view.$root.find(selector)

  render: ->
    # Without format there is no view
    if @view.format.length is 0
      throw new Error 'afinity: empty format in view.render()'
    if @view.$root instanceof jQuery and @_template
      # $root is from DOM already
    else if @view.$root.size() is 0
      @view.$root = $(@view.format)
    else
      # don't overwrite $root as this would reset its presence in the DOM
      # and all events already bound
      @view.$root.html $(@view.format).html()
    # Ensure we have a valid (non-empty) $root
    if !(@view.$root instanceof jQuery) and @view.$root.size() is 0
      throw new Error 'afinity: could not generate html from format'
    @$view = @view.$root
    @$ = @view.$
    return @

  bindings: viewBind

  sync: ->
    # Trigger change events so that view is updated according to model
    @model.each (key, val) => @trigger '_change:' + key
    if @model.size() > 0 then @trigger '_change'
    return @

  stylize: ->

    if @view.style.length == 0 or @view.$().size() == 0 then return

    regex = new RegExp(ROOT_SELECTOR, 'g')
    # Own style
    # Object gets own class name ".afinity_123", and <head> gets a corresponding <style>
    if @view.hasOwnProperty('style')
      objClass = 'afinity_' + @_id
      styleStr = @view.style.replace(regex, '.' + objClass)
      # Add ID so later we can remove generated style upon destruction of object
      $('head', window.document).append """
        <style id="#{objClass}" type="text/css">#{styleStr}</style>
      """
      @view.$().addClass objClass

    else

      # Returns id of first ancestor to have 'own' view.style
      ancestorWithStyle = (object) ->
        while object isnt null
          object = Object.getPrototypeOf(object)
          if object.view.hasOwnProperty('style') then return object._id
        return undefined

      # ancestorWithStyle
      ancestorId = ancestorWithStyle(this)
      objClass = 'afinity_' + ancestorId
      @view.$().addClass objClass

    return @

  $bound: (key) ->

    if @$node[key]? then @$node[key] else false
