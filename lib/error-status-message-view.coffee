class ErrorStatusMessageView extends HTMLElement
	initialize: (@error, bugReportInfo) ->
		errorMessage = @error + ''
		errorDetail = @error?.stack

		@classList.add 'tool-panel', 'panel-bottom', 'padded'
		@textContent = errorMessage

		@removeButton = @createIconButton 'x'
		@removeButton.addEventListener 'click', =>
			@destroy()

		@clipboardButton = @createIconButton 'clippy'
		@clipboardButton.addEventListener 'click', ->
			atom.clipboard.write errorDetail ? errorMessage

		btnGroup = document.createElement 'div'
		btnGroup.classList.add 'btn-group', 'pull-right'

		# If bug-report is installed, show a "report" button that sends error
		# information to bug-report.
		if atom.packages.isPackageLoaded('bug-report')
			@reportButton = @createIconButton 'issue-opened'
			@reportButton.appendChild document.createTextNode ' Report'
			@reportButton.addEventListener 'click', (e) =>
				bugReportInfo.body =
					"## Error\n\n```\n#{errorDetail ? errorMessage}\n```"
				atom.workspaceView.trigger 'bug-report:open', bugReportInfo

				if atom.config.get 'error-status.closeOnReport'
					@destroy()

			btnGroup.appendChild @reportButton

		btnGroup.appendChild @clipboardButton
		btnGroup.appendChild @removeButton

		@appendChild btnGroup

		# If more information (a stack trace) is available, show the more button
		# and add the hidden inset panel.
		if errorDetail
			@expandButton = document.createElement 'span'
			@expandButton.classList.add 'error-expand'
			@expandButton.addEventListener 'click', =>
				if @classList.contains 'expanded'
					@classList.remove 'expanded'
					@expandButton.textContent = '(more...)'
				else
					@classList.add 'expanded'
					@expandButton.textContent = '(less...)'

			@expandButton.textContent = '(more...)'

			@expanded = document.createElement 'div'
			@expanded.classList.add 'inset-panel', 'padded'
			@expanded.textContent = errorDetail

			@appendChild @expandButton
			@appendChild @expanded

	# Helper to create a small button with an icon.
	createIconButton: (iconName) ->
		icon = document.createElement 'span'
		icon.classList.add 'icon', 'icon-' + iconName
		button = document.createElement 'button'
		button.classList.add 'btn', 'btn-sm'
		button.appendChild icon

		button

	attach: ->
		atom.workspaceView.prependToBottom this

	destroy: ->
		@remove()

module.exports = document.registerElement 'error-status-message', prototype: ErrorStatusMessageView.prototype
