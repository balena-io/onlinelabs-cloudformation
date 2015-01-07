_ = require 'lodash'
rp = require 'request-promise'
uuid = require 'uuid'
Promise = require 'bluebird'

util = require './util'

resources =
	# 'Custom::OnlineLabs-IP': require './resources/ip'
	'Custom::OnlineLabs-Server': require './resources/server'
	'Custom::OnlineLabs-Volume': require './resources/volume'

REQUIRED_FIELDS = [
	'LogicalResourceId'
	'RequestId'
	'RequestType'
	'ResourceProperties'
	'ResourceType'
	'ResponseURL'
	'StackId'
]

exports.process = (msg) ->
	new Promise (resolve, reject) ->
		missing = _.difference(REQUIRED_FIELDS, _.keys(msg))
		if missing.length is 0
			resolve(msg)
		else
			reject(new Error("Missing keys: #{missing}"))
	.then (msg) ->
		res = resources[msg.ResourceType]

		if not res?
			throw new Error("Unknown resource type: #{msg.ResourceType}")

		method = msg.RequestType

		if not method in ['Create', 'Update', 'Delete']
			throw new Error("Unknown request type: #{msg.RequestType}")

		return res[method.toLowerCase()](msg)
	.then (res) ->
			Status: 'SUCCESS'
			PhysicalResourceId: res?.PhysicalResourceId or uuid.v4()
			StackId: msg.StackId
			RequestId: msg.RequestId
			LogicalResourceId: msg.LogicalResourceId
			Data: util.denullify(res?.Data)
	.catch (e) ->
		return {
			Status: 'FAILED'
			StackId: msg.StackId
			RequestId: msg.RequestId
			LogicalResourceId: msg.LogicalResourceId
			PhysicalResourceId: uuid.v4()
			Reason: if e instanceof Error then e.toString() else JSON.stringify(e)
		}
	.then JSON.stringify
	.then (body) ->
		rp.put(msg.ResponseURL, {body})
	.catch (e) ->
		console.error("Failed to send response to S3",  e.error)
