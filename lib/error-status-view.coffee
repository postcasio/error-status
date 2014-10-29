ErrorStatusMessageView = require './error-status-message-view'

class ErrorStatusView extends HTMLElement
  initialize: ->
    @errors = []

    @classList.add 'error-status'

    @errorIcon = document.createElement 'span'
    @errorIcon.classList.add 'icon', 'icon-bug'

    @errorCountLabel = document.createElement 'span'

    @appendChild @errorIcon
    @appendChild @errorCountLabel

    @addEventListener 'click', =>
        atom.openDevTools()
        atom.executeJavaScriptInDevTools('InspectorFrontendAPI.showConsole()')
        console.error(error) for error in @errors
        @errors = []
        @updateErrorCount()

    @errorSubscription = atom.on 'uncaught-error', (message, url, line, column, error) =>
        @errors.push error

        if atom.config.get 'error-status.showErrorDetail'
            message = new ErrorStatusMessageView()
            message.initialize(error)
            message.attach()

        @updateErrorCount()

    @updateErrorCount()

  updateErrorCount: ->
      @errorCountLabel.textContent = @errors.length
      if @errors.length > 0
          @classList.add 'has-errors'
      else
          @classList.remove 'has-errors'

  # Tear down any state and detach
  destroy: ->
    @errorSubscription?.off()
    @remove()

module.exports = document.registerElement 'error-status', prototype: ErrorStatusView.prototype
