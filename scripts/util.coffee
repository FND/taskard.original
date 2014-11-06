$ = require("jquery") # TODO: replace jQuery

# wrapper around `jQuery.ajax`, as required by DAV-Dump
exports.http = (method, uri, headers, body) ->
	options =
		type: method
		url: uri
		headers: headers
		data: body
	return new Promise((resolve, reject) ->
		$.ajax(options).
			done((data, status, xhr) ->
				res =
					status: xhr.status
					body: data
					#headers: # not strictly necessary
				resolve(res)).
			fail((xhr, status, err) -> reject(new Error(err))))

exports.indexBy = (prop, items) ->
	reducer = (memo, item) ->
		key = item[prop]
		memo[key] = item
		return memo
	return items.reduce(reducer, {})
