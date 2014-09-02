serializer = require("./serializer")
util = require("./util")

# a WebDAV-based file store, managing the contents of an individual directory
module.exports = class Store
	constructor: (@root, @type) ->

	items: ->
		return @index().then((entries) =>
			items = (@get(entry.name) for entry in entries when !entry.dir)
			return Promise.all(items).
				then((items) -> util.indexBy("title", items)))

	index: ->
		return util.ajax({
			type: "PROPFIND"
			url: @root
			headers: { Depth: 1 }
		}).then((doc) => extractEntries(doc))

	get: (title) ->
		return util.ajax({
			type: "GET"
			url: @uri(title)
		}).then((txt) => serializer.deserialize(title, txt, @type))

	uri: (title) ->
		title = encodeURIComponent(title)
		return [@root, title].join("/")

# extract file names from a WebDAV XML response
extractEntries = (doc) ->
	entries = for entry, i in doc.getElementsByTagNameNS("DAV:", "response")
		parseEntry(entry) if i isnt 0 # skip root -- XXX: brittle
	entries.shift() # skip root -- XXX: duplicates above
	return entries

parseEntry = (entry) ->
	uri = entry.getElementsByTagNameNS("DAV:", "href")[0].textContent
	uri = uri.replace(/\/$/, "") # trim trailing slash
	name = uri.split("/").pop()

	entry =
		name: decodeURIComponent(name)
		dir: !!traverse(entry, "propstat", "prop", "resourcetype",
				"collection")
	return entry

traverse = (root, path...) -> # TODO: rename
	node = root
	while(path.length)
		part = path.shift()
		return null unless node
		node = node.getElementsByTagNameNS("DAV:", part)[0]
	return node
