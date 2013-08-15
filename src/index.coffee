xo =
  _handlers: {}
  handlers: (name) -> (xo._handlers[name] or= [])
  on: (name, handler) ->
    not xo.handlers(name).push(handler)
  emit: (name, args...) ->
    (handler.apply(null, args) for handler in xo.handlers(name)).length > 0
  removeListener: (name, handler) ->
    #array.splice out the handler
    (xo.handlers(name))[t..t] = [] if (t = xo.handlers(name).indexOf(handler)) > -1
  once: (name, handler) ->
    h = (a, b, c, d, e) ->
      xo.removeListener name, h
      handler a, b, c, d, e
    @on name, h

if module?.exports? #node
  module.exports = xo
  $ = require('jquery')
else
  #work around the script wrapper
  window.xo = xo
  $ = window.$

class xo.Agent
  constructor: (config) ->
    this[key] = val for key, val of config
    @__handlers = {}
    for name, handler of @on
      @__handlers[name] = handler.bind this
      xo.on name, @__handlers[name]

  #destroy agent by removing event listeners
  destroy: () ->
    xo.removeListener name, handler for name, handler of @__handlers


class xo.View extends xo.Agent
  constructor: (config) ->
    @children = []
    super config
    if typeof @$ is "string"
      @el = $(@$)
    else if typeof @$ is "function"
      @el = $(@$.call(this))
    @el.bind name, handler.bind(this) for name, handler of @bind

  append: (selector, child) ->
    if child?
      el = @el.find(selector)
    else
      el = @el
      child = selector
    @children.push child
    el.append child.el

  destroy: ->
    child.destroy() for child in @children
    super()
