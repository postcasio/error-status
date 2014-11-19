createNotification = (title, opts={}, events) ->
	notification = new Notification(title, opts)
	for event, callback of events
		notification[event] = callback

module.exports =
	notify: (args...) ->
		if Notification.permission is 'granted'
			createNotification(args...)
		else if Notification.permission isnt 'denied'
			Notification.requestPermission (permission) ->
				createNotification(args...) if permission is 'granted'
