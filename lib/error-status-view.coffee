ErrorStatusMessageView = require './error-status-message-view'

class ErrorStatusView extends HTMLElement
  initialize: ->
    @errors   = []
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

    @errorSubscription = atom.on 'uncaught-error', (message, url, line, column, error) =>
        try
            @errors.push error

            if atom.config.get 'error-status.showErrorDetail'
                message = new ErrorStatusMessageView()
                @messages.unshift message
                message.initialize(error)
                asd()
                message.attach()

            @updateErrorCount()
        catch e
            console.error (error?.stack) ? (error + '')

    process.nextTick =>
      @escapeSubscription = atom.workspaceView.on 'keydown', (e) =>
          if e.which is 27 and @messages.length
              for message, msgIdx in @messages
                  if document.contains message
                      message.destroy(); break
              @messages.splice 0, msgIdx+1
              false

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
    @escapeSubscription?.off()
    @remove()

module.exports = document.registerElement 'error-status', prototype: ErrorStatusView.prototype
