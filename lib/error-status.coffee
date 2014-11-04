ErrorStatusView = require './error-status-view'

module.exports =
	errorStatusView: null
	previousOnError: null

	config:
		showErrorDetail:
			type: 'boolean'
			default: true
			description: 'Show errors in a panel at the bottom of the workspace.'
		closeOnReport:
			type: 'boolean'
			default: true
			description: 'Close the error panel automatically when you report.'

	activate: ->
		@previousOnError = window.onerror

		window.onerror = ->
			atom.lastUncaughtError = Array::slice.call(arguments)
			atom.emit 'uncaught-error', arguments...
			atom.emitter.emit 'did-throw-error', arguments...

		atom.packages.once 'activated', =>
			@attach()

	attach: ->
		@errorStatusView = new ErrorStatusView
		@errorStatusView.initialize()
		atom.workspaceView.statusBar?.appendRight(@errorStatusView)

	deactivate: ->
		@errorStatusView.destroy()
		window.onerror = @previousOnError

	serialize: ->
