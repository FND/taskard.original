# abstraction for managing multiple `Store`s
# each store represents a single project

Store = require("dav-dump")
util = require("./util")

module.exports = class Repository # XXX: no need for this to be a class!?
	constructor: (@root) ->
		root = new Store(@root, util.http)
		@projects = root.index().
			then(([projects, _]) => # TODO: `decodeURIComponent(project)`?
				projectStores = {}
				contents = for project in projects
					store = new Store(@storePath(project), util.http)
					projectStores[project] = store
					store.all() # prefetch -- XXX: unnecessary?
				return Promise.all(contents).then(-> projectStores))

	storePath: (project) ->
		return [@root, project].join("/") # TODO: `encodeURIComponent`?
