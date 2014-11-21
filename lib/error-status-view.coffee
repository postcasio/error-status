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

		# Log our error history when the error count is clicked.
		@addEventListener 'click', =>
			atom.openDevTools()
			atom.executeJavaScriptInDevTools('InspectorFrontendAPI.showConsole()')
			for error in @errors
					console.error (error?.stack) ? (error + '')

			@errors = []
			@updateErrorCount()

		# Listen for errors from Atom.
		@errorSubscription = atom.onWillThrowError ({message, originalError, preventDefault}) =>
			try
				@errors.push originalError

				createMessageView = =>
					bugReportInfo =
							title: message
							time: Date.now()
					messageView = new ErrorStatusMessageView()
					@messages.unshift messageView
					messageView.initialize(originalError, bugReportInfo)
					messageView.attach()

				if atom.config.get 'error-status.showErrorDetail'
					if atom.config.get 'error-status.useNotifications'
						# If using notifications, we only create the message view when the notification is clicked.
						opts = {}
						if originalError?.stack
							opts.body = originalError.stack
						notify message, opts,
							onclick: createMessageView
					else
						# Create the message view now.
						createMessageView()

				@updateErrorCount()

				# We handled the error, so prevent Atom handling it too.
				preventDefault()

			catch error
				# Something went horribly wrong.
				# Do nothing, and Atom will handle the error.


		# Remove the latest error when escape is pressed.
		@escapeSubscription = atom.workspaceView.on 'keydown', (e) =>
			if e.which is 27 and @messages.length
				for message, msgIdx in @messages
					if document.contains message
						message.destroy()
						break
				@messages.splice 0, msgIdx + 1

		@updateErrorCount()

	# Update the status bar with the new error count.
	updateErrorCount: ->
		@errorCountLabel.textContent = @errors.length
		@classList.toggle 'has-errors', @errors.length > 0

	# Tear down any state and detach
	destroy: ->
		@errorSubscription?.off()
		@escapeSubscription?.off()
		@remove()

module.exports = document.registerElement 'error-status', prototype: ErrorStatusView.prototype
