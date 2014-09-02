rivets = require("rivets")
Store = require("./store")

data =
	"task-states": ["to do", "in progress", "under review", "done"]
	matrix: []

node = document.querySelector(".board")
rivets.bind(node, data)

base = document.location.toString().split("/")[...-1].join("/")
storePath = (directory) ->
	parts = [base, "store"] # XXX: hard-coded root directory
	parts.push(directory) if directory
	return parts.join("/")

populate = (projects) ->
	for project, tasks of projects
		# index tasks by state
		index = {}
		for title, task of tasks
			task.category ?= "" # XXX: hacky -- XXX: belongs into serializer!?
			index[task.state] ?= []
			index[task.state].push(task)

		data.matrix.push({ # XXX: inefficient WRT Rivets re-rendering?
			title: project
			tasks: (index[state] for state in data["task-states"])
		})

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
