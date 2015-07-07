###
#
# afinity - version 0.5.3
#
# Originally based on Agility.js by Artur B. Adib - http://agilityjs.com
# Forked, pulled requests, modularized, extended, refactored and caffeinated
#
###

((window) ->

  AfinityFactory =
    create : require('./base/create')
    load : require('./base/load')
    launch : require('./base/launch')
    addMethods : require('./base/methods')

  defaultPrototype = require('./prototype')
  util = require('./util')

  # Afinity object factory
  afinity = (args...) ->

    prototype = defaultPrototype

    # If first arg is an afinity object, use it as prototype
    if util.isAfinity args[0]
      prototype = args[0]
      args.shift()

    # Create new object from prototype
    object = AfinityFactory.create prototype

    # Load model/view/events from arguments
    if args.length > 0 then AfinityFactory.load object, args

    # Launch init sequence
    return AfinityFactory.launch object

  # Give it some root methods
  AfinityFactory.addMethods afinity

  # Shortcut to prototype for inherited extensions
  afinity.fn = defaultPrototype

  # Export it - AMD, CommonJS, then global
  if typeof define is 'function' and define.amd
    define [], -> afinity
  else if typeof exports is 'object'
    module.exports = afinity
  else
    window.afinity = afinity

  return

) window
