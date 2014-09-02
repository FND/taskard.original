rivets = require("rivets")
Store = require("./store")

data =
	"task-states": ["to do", "in progress", "under review", "done"]
	projects: ["foo", "bar"]

node = document.querySelector(".board")
rivets.bind(node, data)

base = document.location.toString().split("/")[...-1].join("/")
storePath = (directory) ->
	parts = [base, "store"] # XXX: hard-coded root directory
	parts.push(directory) if directory
	return parts.join("/")

loadProjects = ([projects, _]) ->
	index = {}
	items = for project in projects
		register = do (project) ->
			return (items) -> index[project] = items
		store = new Store(storePath(project))
		store.items().then(register)
	return Promise.all(items).then(-> index)

store = new Store(storePath()) # projects
store.index().then(loadProjects).then((projects) -> console.dir(projects)).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
