xo =
  handlers: {}
  on: (name, handler) ->
    not (xo.handlers[name] or= []).push(handler)
  emit: (name, args...) ->
    (handler.apply(null, args) for handler in xo.handlers[name] or []).length > 0
  removeListener: (name, listener) ->
    for handler in xo.handlers[name]
      delete xo.handlers[name] if listener is handler


class xo.Agent
  constructor: (@config) ->
    this[key] = val for key, val of @config
    for name, handler of @on
      @__handlers or= {}
      xo.on name, this.__handlers[name] = handler.bind this

  #destroy agent by removing event listeners
  destroy: () ->
    xo.removeListener name, handler for name, handler of @__handlers


class xo.View extends xo.Agent
  constructor: (@config) ->
    super @config
    @el = $(@$) if @$
    @el.bind name, handler.bind(this) for name, handler of @bind

if module?.exports?
  module.exports = xo
else
  window.xo = xo
