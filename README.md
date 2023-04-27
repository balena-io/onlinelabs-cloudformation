OnlineLabs Cloudformation
========

This projects allows you to include OnlineLabs Resources in your CloudFormation stacks

Resources
---------

The library currently implements Create and Delete requests for the following resources

- Servers
- Volumes

Usage
-----

In order to create Custom CloudFormation resources you will have to include a SNS resource in your stack definition and add an http subscriber to that
resource that points to a server running this project.

The `Properties` object defined in the cloudformation stack is passed as-is to the onlinelabs API except for the `ServiceToken`, which is used by AWS to
send the messages, and `AuthToken` which gets converted to the `X-Auth-Token` header in the requests hitting the onlinelabs API.

Examples
-------

Here is an example stack that starts a server

```json
{
	"Resources": {
		"OnlineLabs": {
			"Type": "AWS::SNS::Topic",
			"Properties": {
				"Subscription": [{ "Endpoint": "<YOUR ENDPOINT>", "Protocol": "https" }]
			}
		},

		"MyARMServer": {
			"Type": "Custom::OnlineLabs-Server",
			"Properties": {
				"ServiceToken": { "Ref": "OnlineLabs" },
				"AuthToken": "<YOUR AUTH TOKEN>",

				"name": "MyARMServer",
				"organization": "<YOUR ORGANIZATION UUID>",
				"image": "<IMAGE UUID>",
			}
		}
	}
}
```

Here is an example stack that starts a server that also has an additional volume attached

```json
{
	"Resources": {
		"OnlineLabs": {
			"Type": "AWS::SNS::Topic",
			"Properties": {
				"Subscription": [{ "Endpoint": "<YOUR ENDPOINT>", "Protocol": "https" }]
			}
		},

		"MyARMVolume": {
			"Type": "Custom::OnlineLabs-Volume",
			"Properties": {
				"ServiceToken": { "Ref": "OnlineLabs" },
				"AuthToken": "<YOUR ONLINELABS AUTH TOKEN>",

				"name": "MyVolume",
				"organization": "<YOUR ORGANIZATION UUID>",
				"volume_type": "l_ssd",
				"size": 10000000000
			}
		},

		"MyARMServer": {
			"Type": "Custom::OnlineLabs-Server",
			"Properties": {
				"ServiceToken": { "Ref": "OnlineLabs" },
				"AuthToken": "<YOUR ONLINELABS AUTH TOKEN>",

				"name": "MyARMServer",
				"organization": "<YOUR ORGANIZATION UUID>",
				"image": "<IMAGE UUID>",

				"volumes": {
					"1": { "Ref": "MyARMVolume" }
				}
			}
		}
	}
}
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/onlinelabs-cloudformation/issues) on GitHub.

TODO
-------

- Support IPs
- Support Snapshots
- Support updating of resources

License
-------

The project is licensed under the MIT license.
