_ = require 'lodash'
rp = require 'request-promise'

exports.makeClient = (msg) ->
	client = rp.defaults(
		json: true
		headers:
			'X-Auth-Token': msg.ResourceProperties.AuthToken
	)

	body = _.cloneDeep(msg.ResourceProperties)

	delete body.AuthToken
	delete body.ServiceToken

	return [client, body]

exports.denullify = denullify = (obj) ->
	_.mapValues(obj, (v) ->
		if v is null
			undefined
		else if typeof v is 'object'
			denullify(v)
		else
			v
	)

