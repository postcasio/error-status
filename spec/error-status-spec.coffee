{WorkspaceView} = require 'atom'

describe "error-status", ->
	workspaceElement = null
	errorStatusElement = null
	keymapManager = null

	throwError = (error) -> window.onerror 'Error message', 'error-status-spec.coffee', 1, 1, error

	beforeEach ->
		atom.workspaceView = new WorkspaceView
		atom.workspace = atom.workspaceView.model
		atom.workspaceView.attachToDom()
		workspaceElement = atom.workspaceView[0]

		waitsForPromise -> atom.packages.activatePackage('status-bar')
		waitsForPromise -> atom.packages.activatePackage('error-status')
		runs ->
			atom.packages.getActivePackage('error-status').mainModule.attach()
			errorStatusElement = workspaceElement.querySelector('error-status')
			atom.config.set 'error-status.showErrorDetail', true
			keymapManager = require('atom-keymap')

	describe "error-status", ->
		it "attaches the error view when error detail is enabled", ->
			throwError(new Error)
			expect(workspaceElement.querySelector('error-status-message')).toExist()
		it "does not attach the error view when error detail is disabled", ->
			atom.config.set 'error-status.showErrorDetail', false
			throwError(new Error)
			expect(workspaceElement.querySelector('error-status-message')).not.toExist()
		it "increases the error count in the status bar", ->
			throwError(new Error)
			expect(errorStatusElement.errors.length).toBe(1)
			expect(errorStatusElement.errorCountLabel.textContent).toBe('1')
			throwError(new Error)
			expect(errorStatusElement.errors.length).toBe(2)
			expect(errorStatusElement.errorCountLabel.textContent).toBe('2')
		it "clears the error count when clicking on the status bar icon", ->
			throwError(new Error)
			errorStatusElement.dispatchEvent(new Event('click'))
			expect(errorStatusElement.errors.length).toBe(0)
			expect(errorStatusElement.errorCountLabel.textContent).toBe('0')
		it "logs the errors to console when clicking on the status bar icon", ->
			spyOn(console, 'error')
			throwError(new Error)
			errorStatusElement.dispatchEvent(new Event('click'))
			expect(console.error.callCount).toBe(1)
		it "gains the has-errors class only when there are errors", ->
			expect(errorStatusElement.classList.contains('has-errors')).toBe(false)
			throwError(new Error)
			expect(errorStatusElement.classList.contains('has-errors')).toBe(true)
			errorStatusElement.dispatchEvent(new Event('click'))
			expect(errorStatusElement.classList.contains('has-errors')).toBe(false)
		it "shows the more link when an error has more detail", ->
			throwError(new Error)
			expect(workspaceElement.querySelector('error-status-message span.error-expand')).toExist()
		it "does not show the more link when an error has no detail", ->
			throwError(null)
			expect(workspaceElement.querySelector('error-status-message span.error-expand')).not.toExist()
		it "closes the last error when escape is pressed", ->
			throwError(new Error)
			throwError(new Error)
			workspaceElement.dispatchEvent(keymapManager.keydownEvent('escape', keyCode: 27))
			expect(workspaceElement.querySelectorAll('error-status-message').length).toBe(1)
			workspaceElement.dispatchEvent(keymapManager.keydownEvent('escape', keyCode: 27))
			expect(workspaceElement.querySelector('error-status-message')).not.toExist()
