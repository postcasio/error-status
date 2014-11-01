class ErrorStatusMessageView extends HTMLElement
	initialize: (@error) ->
		errorMessage = @error + ''
		errorDetail = @error?.stack

		@classList.add 'tool-panel', 'panel-bottom', 'padded'
		@textContent = errorMessage

		@removeButton = @createIconButton 'x'
		@removeButton.addEventListener 'click', =>
			@destroy()

		@clipboardButton = @createIconButton 'clippy'
		@clipboardButton.addEventListener 'click', =>
			atom.clipboard.write errorDetail

		btnGroup = document.createElement 'div'
		btnGroup.classList.add 'btn-group', 'pull-right'

		if atom.packages.isPackageLoaded('bug-report')
			@reportButton = @createIconButton 'issue-opened'
			@reportButton.appendChild document.createTextNode ' Report'
			@reportButton.addEventListener 'click', (e) =>
				info = "## Error\n\n```\n#{errorDetail ? errorMessage}\n```"
				atom.workspaceView.trigger 'bug-report:open', info

				if atom.config.get 'error-status.closeOnReport'
					@destroy()

			btnGroup.appendChild @reportButton

		btnGroup.appendChild @clipboardButton
		btnGroup.appendChild @removeButton

		@appendChild btnGroup

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
