ErrorStatusView = require './error-status-view'

module.exports =
  errorStatusView: null
  previousOnError: null

  config:
    showErrorDetail:
      type: 'boolean'
      default: true
      description: 'Show errors in a panel at the bottom of the workspace.'

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
