# a WebDAV-based file store, managing the contents of an individual directory
# inspired by TiddlyWeb's text store
# `item`s are key-value pairs identified by `title`

serializer = require("./serializer")
util = require("./util")

module.exports = class Store
	constructor: (@root, @type) ->

	items: ->
		return @index().then(([dirs, files]) =>
			items = (@get(file) for file in files)
			return Promise.all(items).
				then((items) -> util.indexBy("title", items)))

	index: ->
		return util.ajax({
			type: "PROPFIND"
			url: @root
			headers: { Depth: 1 }
		}).then((doc) => extractEntries(doc))

	add: (item) -> # XXX: clobbers, subject to race conditions (conflicts), doesn't update indexes
		title = item.title
		throw new Error("missing title") unless title

		return util.ajax({
			type: "PUT",
			url: @uri(title),
			headers: { "Content-Type": "text/plain" }, # XXX: should not be necessary!?
			data: serializer.serialize(item)
		})

	delete: (title) ->
		return util.ajax({
			type: "DELETE",
			url: @uri(title)
		})

	move: (title, store) ->
		return util.ajax({
			type: "MOVE",
			url: @uri(title),
			headers: { "Destination": store.uri(title) }
		})

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
	dirs = []
	files = []
	for entry, i in doc.getElementsByTagNameNS("DAV:", "response")
		entry = parseEntry(entry)
		continue if i is 0 # skip root -- XXX: brittle?
		list = if entry.dir then dirs else files # TODO: use `reduce` instead?
		list.push(entry.name)

	return [dirs, files]

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
