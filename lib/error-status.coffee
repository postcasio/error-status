ErrorStatusView = require './error-status-view'

module.exports =
	errorStatusView: null

	config:
		showErrorDetail:
			type: 'boolean'
			default: true
			description: 'Show errors in a panel at the bottom of the workspace.'
		closeOnReport:
			type: 'boolean'
			default: true
			description: 'Close the error panel automatically when you report.'
		useNotifications:
			type: 'boolean'
			default: false
			description: 'Use Notification API. Clicking notifications will open the error panel.'

	activate: ->
		# We need status-bar to be active before we can attach the view.
		atom.packages.once 'activated', =>
			@attach()

	attach: ->
		@errorStatusView = new ErrorStatusView
		@errorStatusView.initialize()
		atom.workspaceView.statusBar?.appendRight(@errorStatusView)

	deactivate: ->
		@errorStatusView.destroy()

	serialize: ->
