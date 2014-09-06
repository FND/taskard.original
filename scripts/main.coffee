rivets = require("rivets")
Board = require("./board")
Store = require("./store")

registry = {} # project stores
board = new Board(".board", ["to do", "in progress", "review pending", "done"],
		registry)

form =
	projects: []
	categories: ["", "urgent", "important", "casual"]
	onSubmit: (ev, rv) ->
		ev.preventDefault()
		task =
			title: rv.task
			category: rv.selectedCategory
			state: board["task-states"][0] # XXX: hard-coded

		projects = this.parentNode.getElementsByClassName("radios")[0]. # XXX: should use Rivets for this
			getElementsByTagName("input")
		for radio in projects
			selectedProject = radio.value if radio.checked
		return unless selectedProject # TODO: user notification

		store = registry[selectedProject] # XXX: might not be populated yet
		store.add(task) # TODO: error handling -- TODO: UI updates

node = document.querySelector("form.task")
rivets.bind(node, form)

base = document.location.toString().split("/")[...-1].join("/")
storePath = (directory) ->
	parts = [base, "store"] # XXX: hard-coded root directory
	parts.push(directory) if directory
	return parts.join("/")

init = (projects) ->
	board.init(projects)

	for project, tasks of projects
		form.projects.push(project)

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
