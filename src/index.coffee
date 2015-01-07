Promise = require 'bluebird'
request = Promise.promisifyAll require('request')
express = require 'express'
resource = require './resource'
bodyParser = require 'body-parser'

app = express()

app.use bodyParser.text()

app.post '/', (req, res) ->
	console.log("SENDING OK TO SNS")
	res.sendStatus(200)

	Promise.resolve(req.body)
	.then JSON.parse
	.then (body) ->
		console.log(body)
		switch body.Type
			when 'SubscriptionConfirmation'
				request.getAsync(body.SubscribeURL)
			when 'Notification'
				console.log("Processing message", body.Message)
				resource.process(JSON.parse(body.Message))
	.catch(->)

app.listen(process.env.PORT or 8080)
