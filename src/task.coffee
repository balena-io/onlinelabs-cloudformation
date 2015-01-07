Promise = require 'bluebird'

TASK_ENDPOINT = 'https://api.cloud.online.net/tasks'

exports.wait = wait = (client, id, ms=2000) ->
	Promise.delay(ms)
	.then ->
		client.get("#{TASK_ENDPOINT}/#{id}")
	.then (body) ->
		switch body.task.status
			when 'pending'
				wait(client, id, ms)
			when 'success'
				return
			else
				throw new Error('Task failed')

