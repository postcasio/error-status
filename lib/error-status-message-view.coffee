class ErrorStatusMessageView extends HTMLElement
	initialize: (@error) ->
		@classList.add 'tool-panel', 'panel-bottom', 'padded'
		@textContent = @error.toString()

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

		@removeButton = document.createElement 'span'
		@removeButton.classList.add 'pull-right', 'icon', 'icon-x'
		@removeButton.addEventListener 'click', =>
			@destroy()

		@expanded = document.createElement 'div'
		@expanded.classList.add 'inset-panel', 'padded'
		@expanded.textContent = error.stack ? 'No stacktrace available.'

		@appendChild @expandButton
		@appendChild @removeButton
		@appendChild @expanded

	attach: ->
		atom.workspaceView.prependToBottom this

	destroy: ->
		@remove()

module.exports = document.registerElement 'error-status-message', prototype: ErrorStatusMessageView.prototype
