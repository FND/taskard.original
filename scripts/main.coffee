rivets = require("rivets")
Board = require("./board")
TaskForm = require("./task_form")
Store = require("./store")

registry = {} # project stores
board = new Board(".board", ["to do", "in progress", "review pending", "done"],
		registry)
form = new TaskForm("form.task", board, registry)

basePath = document.location.toString().split("/")[...-1].join("/")
storePath = (directory) ->
	parts = [basePath, "store"] # XXX: hard-coded root directory
	parts.push(directory) if directory
	return parts.join("/")

init = (projects) ->
	board.init(projects)
	form.init(projects)

loadTasks = ([projects, _]) ->
	index = {} #
	items = for project in projects
		register = do (project) ->
			return (items) -> index[project] = items
		store = new Store(storePath(project))
		registry[project] = store
		store.items().then(register)
	return Promise.all(items).then(-> index)

projects = new Store(storePath()) # projects
projects.index().then(loadTasks).then(init).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
