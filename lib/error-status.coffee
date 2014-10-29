ErrorStatusView = require './error-status-view'

module.exports =
  errorStatusView: null
  previousOnError: null

  activate: ->
    @previousOnError = window.onerror

    window.onerror = ->
      atom.lastUncaughtError = Array::slice.call(arguments)
      atom.emit 'uncaught-error', arguments...

    @errorStatusView = new ErrorStatusView
    atom.packages.once 'activated', =>
      @errorStatusView.initialize()
      atom.workspaceView.statusBar?.appendRight(@errorStatusView)

  deactivate: ->
    @errorStatusView.destroy()
    window.onerror = @previousOnError

  serialize: ->
