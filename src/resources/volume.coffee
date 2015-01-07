debug = require('debug')('online-cfn:volume')
Promise = require 'bluebird'

util = require '../util'

VOLUME_ENDPOINT = 'https://api.cloud.online.net/volumes'

module.exports =
	create: (msg) ->
		[client, body] = util.makeClient(msg)
		debug('create:', body)

		body.size = parseInt(body.size, 10)

		# Create a volume
		client.post("#{VOLUME_ENDPOINT}", {body})
		.promise()
		.get('volume')
		# Return info to CloudFormation
		.then (vol) ->
			debug('create: Volume created')
			PhysicalResourceId: vol.id
	update: (msg) ->
		throw new Error('Update not implemented')
	delete: (msg) ->
		[client, body] = util.makeClient(msg)

		id = msg.PhysicalResourceId

		# Delete volume
		client.del("#{VOLUME_ENDPOINT}/#{id}")
		# Return info to CloudFormation
		.promise()
		.return(PhysicalResourceId: id)
