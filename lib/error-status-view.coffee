ErrorStatusMessageView = require './error-status-message-view'
{notify} = require './notifications'

class ErrorStatusView extends HTMLElement
	initialize: ->
		@errors	 = []
		@messages = []

		@classList.add 'error-status'

		@errorIcon = document.createElement 'span'
		@errorIcon.classList.add 'icon', 'icon-bug'

		@errorCountLabel = document.createElement 'span'

		@appendChild @errorIcon
		@appendChild @errorCountLabel

		@addEventListener 'click', =>
			atom.openDevTools()
			atom.executeJavaScriptInDevTools('InspectorFrontendAPI.showConsole()')
			for error in @errors
					console.error (error?.stack) ? (error + '')

			@errors = []
			@updateErrorCount()

		@errorSubscription = atom.on 'uncaught-error', (errorMessage, url, line, column, error) =>
			try
				@errors.push error

				createMessageView = =>
					bugReportInfo =
							title: errorMessage
							time: Date.now()
					message = new ErrorStatusMessageView()
					@messages.unshift message
					message.initialize(error, bugReportInfo)
					message.attach()

				if atom.config.get 'error-status.showErrorDetail'
					if atom.config.get 'error-status.useNotifications'
						opts = {}
						if error?.stack
							opts.body = error.stack
						notify error + '', opts,
							onclick: createMessageView
					else
						createMessageView()

				@updateErrorCount()
			catch e
				console.error e
				console.error (error?.stack) ? (error + '')


		@escapeSubscription = atom.workspaceView.on 'keydown', (e) =>
			if e.which is 27 and @messages.length
				for message, msgIdx in @messages
					if document.contains message
						message.destroy()
						break
				@messages.splice 0, msgIdx + 1


		@updateErrorCount()

	updateErrorCount: ->
		@errorCountLabel.textContent = @errors.length
		@classList.toggle 'has-errors', @errors.length > 0

	# Tear down any state and detach
	destroy: ->
		@errorSubscription?.off()
		@escapeSubscription?.off()
		@remove()

module.exports = document.registerElement 'error-status', prototype: ErrorStatusView.prototype
