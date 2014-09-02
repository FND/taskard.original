$ = require("jquery") # TODO: replace jQuery

# wrapper around `jQuery.ajax`, making the return value Promises/A+ compatible
exports.ajax = (args...) ->
	return new Promise((resolve, reject) ->
		$.ajax(args...).
			done((data, status, xhr) -> resolve(data)). # XXX: discarding `xhr`
			fail((xhr, status, err) -> reject(new Error(err))))

exports.indexBy = (prop, items) ->
	reducer = (memo, item) ->
		key = item[prop]
		memo[key] = item
		return memo
	return items.reduce(reducer, {})
