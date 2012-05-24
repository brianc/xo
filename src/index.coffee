xo =
  handlers: {}
  on: (name, handler) ->
    not (xo.handlers[name] or= []).push(handler)
  emit: (name, args...) ->
    (handler.apply(null, args) for handler in xo.handlers[name] or []).length > 0

class xo.Agent
  constructor: (@config) ->
    this[key] = val for key, val of @config
    xo.on name, handler.bind(this) for name, handler of @on

class xo.View extends xo.Agent
  constructor: (@config) ->
    super @config
    @el = $(@$) if @$
    @el.bind name, handler.bind(this) for name, handler of @bind

if module?.exports?
  module.exports = xo
else
  window.xo = xo
