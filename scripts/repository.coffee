# abstraction for managing multiple `Store`s
# each store represents a single project

Store = require("dav-dump")
http = require("./util").http

module.exports = class Repository
	constructor: (@root, @taskStates) ->
		@store = new Store(@root, http)

	# `callback` is invoked once per project, passing the project name and tasks
	# indexed by title
	# returns a promise for the list of projects (without waiting for tasks)
	load: (callback) -> # TODO: rename
		return @store.index().
			then(([projects, _]) =>
				for project in projects
					store = new Store(@storePath(project), http)
					notify = do (project) ->
						return (tasks) -> callback(project, tasks)
					store.all().then(notify)
				return projects)

	storePath: (project) ->
		return [@root, project].join("/") # TODO: `encodeURIComponent`?
