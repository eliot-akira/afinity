###
#
# View bindings
#
#  Apply DOM <-> Model bindings, from elements with 'data-bind' attributes
#
# TODO: Replace self with => and @
#
###

# Using: DOM events and methods
$ = require 'jquery'

###
#
# Parse data-bind string
#
# Syntax:'[attribute][=] variable[, [attribute][=] variable ]...'
#
# All pairs in the list are assumed to be attributes
# If the variable is not an attribute, it must occur by itself
#
# Returns { key:'model key', attr: [ {attr : 'attribute', attrVar : 'variable' }... ] }
#
###

_parseBindStr = (str) ->
  obj =
    key: null
    attr: []
  pairs = str.split(',')
  regex = /([a-zA-Z0-9_\-\.]+)(?:[\s=]+([a-zA-Z0-9_\-]+))?/
  keyAssigned = false
  matched = undefined
  if pairs.length > 0
    i = 0
    while i < pairs.length
      matched = pairs[i].match(regex)

      # [ "attribute variable", "attribute", "variable" ]
      # or [ "attribute=variable", "attribute", "variable" ]
      # or [ "variable", "variable", undefined ]
      # in some IE it will be [ "variable", "variable", "" ]
      # or null
      if matched
        if typeof matched[2] == 'undefined' or matched[2] == ''
          if keyAssigned
            throw new Error('You may specify only one key (' + keyAssigned + ' has already been specified in data-bind=' + str + ')')
          else
            keyAssigned = matched[1]
            obj.key = matched[1]
        else
          obj.attr.push
            attr: matched[1]
            attrVar: matched[2]
      # End: if (matched)
      i++
    # End: for (pairs.length)
  # End: if (pairs.length > 0)
  return obj

module.exports = ->
  self = this # Reference to object
  $rootNode = @view.$().filter('[data-bind]')
  $childNodes = @view.$('[data-bind]')

  createAttributePairClosure = (bindData, node, i) ->
    attrPair = bindData.attr[i]
    # capture the attribute pair in closure
    return ->
      if attrPair.attr is 'html'
        # Allow inserting HTML content
        node.html self.model.get(attrPair.attrVar)
      else
        # Normal element attributes
        node.attr attrPair.attr, self.model.get(attrPair.attrVar)
      return

  $rootNode.add($childNodes).each ->

    $node = $(this)
    bindData = _parseBindStr $node.data('bind') or ''
    required = $node.data('required')
    # data-required

    bindAttributesOneWay = ->
      # 1-way attribute binding
      if bindData.attr
        i = 0
        while i < bindData.attr.length
          self.bind '_change:' + bindData.attr[i].attrVar, createAttributePairClosure(bindData, $node, i)
          i++
        # for (bindData.attr)
      # if (bindData.attr)
      return

    if bindData.key

      ###---------------------------------------------
      #
      # Input types
      #
      ###

      # <input type="checkbox">: 2-way binding
      if $node.is('input:checkbox')
        # Model --> DOM
        self.bind '_change:' + bindData.key, ->
          $node.prop 'checked', self.model.get bindData.key
        # DOM --> Model
        $node.change ->
          self.model.set bindData.key, $node.prop('checked'), direct:true

      else if $node.is('select')
        # Model --> DOM
        self.bind '_change:' + bindData.key, ->
          $node.val self.model.get bindData.key
        # DOM --> Model
        $node.change ->
          self.model.set bindData.key, $node.val(), direct:true

      else if $node.is('input:radio')
        # Model --> DOM
        self.bind '_change:' + bindData.key, ->
          # Binding for radio buttons: they're not always siblings, so start from $root
          self.view.$root
            .find('input[name="' +  $node.attr('name') + '"]')
            .filter('[value="' + self.model.get(bindData.key) + '"]')
            .prop 'checked', true
        # DOM --> Model
        $node.change ->
          # only handle check=true events
          if !$node.prop('checked') then return
          self.model.set bindData.key, $node.val(), direct:true

      else if $node.is('input:text, textarea, input[type="search"]')
        # Model --> DOM
        self.bind '_change:' + bindData.key, ->
          $node.val self.model.get(bindData.key)
        # Model <-- DOM
        $node.keyup -> # instead of $node.change ->
          # Without timeout, $node.val() misses the last entered character
          setTimeout ->
            self.model.set bindData.key, $node.val(), direct:true
          , 50
          return
      else
        # Not an input element
        # Model --> DOM
        self.bind '_change:' + bindData.key, =>
          key = self.model.get bindData.key
          if key or key is 0 then $node.text self.model.get(bindData.key).toString()
          else $node.text ''
          return

      # End: input types
    # End: if bindData.key

    # Model -> DOM attributes
    bindAttributesOneWay()

    # Custom bindings
    bindData.attr.forEach (pair, index) ->
      # Keyup
      if pair.attr is 'keyup'
        $node.keyup ->
          # timeout to make sure to get last entered character
          setTimeout (->
            self.model.set pair.attrVar, $node.val()
            # fires event
            return
          ), 50
          return
        # Model -> View
        self.bind '_change:' + pair.attrVar, ->
          $node.val self.model.get(pair.attrVar)
          return

      # Visible
      else if pair.attr is 'visible'
        # If prop is true then make visible
        # Model -> View
        self.bind '_change:' + pair.attrVar, ->
          if self.model.get(pair.attrVar) then $node.show()
          else $node.hide()
          return
      else
        # TODO: Extensible custom bindings
      return

    # Store binding map for later reference
    self.$node[bindData.key] = $node
    # Model property -> element
    self.key[$node] = bindData.key

    # Element -> Model property
    if required then self.required[bindData.key] = required

    return

  # nodes.each()
  return @
