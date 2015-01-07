debug = require('debug')('online-cfn:server')
Promise = require 'bluebird'

task = require '../task'
util = require '../util'

SERVER_ENDPOINT = 'https://api.cloud.online.net/servers'
VOLUME_ENDPOINT = 'https://api.cloud.online.net/volumes'

POWER_ON =
	action: 'poweron'
POWER_OFF =
	action: 'poweroff'

module.exports =
	create: (msg) ->
		[client, body] = util.makeClient(msg)
		debug('create:', body)

		# Create a server
		client.post("#{SERVER_ENDPOINT}", {body})
		.promise()
		.tap (res) ->
			debug('create: Server created')
			# Start the server we just created
			client.post("#{SERVER_ENDPOINT}/#{res.server.id}/action", body: POWER_ON)
			.then (res) ->
				# Wait for the server to start
				task.wait(client, res.task.id)
		.then (res) ->
			debug('create: Server started')
			# Get info only available after starting (e.g IP address)
			client.get("#{SERVER_ENDPOINT}/#{res.server.id}")
		# Return info to CloudFormation
		.get('server')
		.then (srv) ->
			PhysicalResourceId: srv.id
			Data:
				ImageId:     srv.image.id
				ImageName:   srv.image.name
				Name:        srv.name
				PrivateIp:   srv.private_ip.address
				PublicIp:    srv.public_ip.address
	update: (msg) ->
		throw new Error('Update not implemented')
	delete: (msg) ->
		[client, body] = util.makeClient(msg)

		id = msg.PhysicalResourceId

		# Get server details
		client.get("#{SERVER_ENDPOINT}/#{id}")
		.promise()
		.get('server')
		.tap (srv) ->
			if srv.state is 'running'
				# Stop the server
				client.post("#{SERVER_ENDPOINT}/#{id}/action", body: POWER_OFF)
				.then (res) ->
					# Wait for the server to stop
					task.wait(client, res.task.id)
		.tap ->
			# Delete server
			client.del("#{SERVER_ENDPOINT}/#{id}")
		.then (srv)->
			# Delete root volume
			client.del("#{VOLUME_ENDPOINT}/#{srv.volumes[0].id}")
		# Return info to CloudFormation
		.return(PhysicalResourceId: id)
