rivets = require("rivets")
Store = require("./store")

data =
	"task-states": ["to do", "in progress", "under review", "done"]
	projects: []

node = document.querySelector(".board")
rivets.bind(node, data)

base = document.location.toString().split("/")[...-1].join("/")
storePath = (directory) ->
	parts = [base, "store"] # XXX: hard-coded root directory
	parts.push(directory) if directory
	return parts.join("/")

populate = (projects) ->
	for project, tasks of projects
		project =
			title: project
			tasks: (task for title, task of tasks)
		data.projects.push(project) # XXX: inefficient WRT Rivets re-rendering?

loadProjects = ([projects, _]) ->
	index = {}
	items = for project in projects
		register = do (project) ->
			return (items) -> index[project] = items
		store = new Store(storePath(project))
		store.items().then(register)
	return Promise.all(items).then(-> index)

store = new Store(storePath()) # projects
store.index().then(loadProjects).then(populate).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
