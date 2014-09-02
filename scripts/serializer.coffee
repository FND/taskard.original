# inspired by TiddlyWeb's text store, which uses an RFC 822-style format
# `tid`s are key-value pairs with two special slots: `title` and `body`

util = require("./util")

# XXX: somewhere extra "----" lines (i.e. such not functioning as separators)
# are being swallowed

exports.serialize = (tid, type) ->
	headers = []
	for key, value of tid
		if key is "title"
			title = value # unused
		else if key is "body"
			body = value
		else
			header = [key, value].join(": "); # TODO: encode (line breaks, colons)
			headers.push(header)

	return headers.concat(["", body]).join("\n")

exports.deserialize = (title, txt, type) ->
	[headers, body] = part(txt, "\n\n")
	headers = headers.split("\n")
	body = body.trim()

	tid = {}
	for line in headers
		[key, value] = part(line, ": ")
		tid[key] = value

	tid.title = title
	tid.body = body

	return tid

# split into two parts
part = (str, delimiter) ->
	parts = str.split(delimiter)
	return [parts[0], parts[1..].join(delimiter)]