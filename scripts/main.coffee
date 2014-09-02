rivets = require("rivets")
Store = require("./store")

# XXX: too many globals => move into Board class?

stores = {}

board =
	"task-states": ["to do", "in progress", "under review", "done"]
	matrix: []
	onRemove: (ev, rv) ->
		store = stores[rv.project.title] # XXX: might not be populated yet
		store.delete(rv.task.title). # TODO: error handling
			then(=> # XXX: should use Rivets for UI updates
				node = this.parentNode
				node.parentNode.removeChild(node))

node = document.querySelector(".board")
rivets.bind(node, board)

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

		store = stores[selectedProject] # XXX: might not be populated yet
		store.add(task) # TODO: error handling -- TODO: UI updates

node = document.querySelector("form.task")
rivets.bind(node, form)

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

		# XXX: `push`ing inefficient WRT Rivets re-rendering?

		board.matrix.push({
			title: project
			tasks: (index[state] for state in board["task-states"])
		})

		form.projects.push(project)

loadProjects = ([projects, _]) ->
	index = {}
	items = for project in projects
		register = do (project) ->
			return (items) -> index[project] = items
		store = new Store(storePath(project))
		stores[project] = store
		store.items().then(register)
	return Promise.all(items).then(-> index)

projects = new Store(storePath()) # projects
projects.index().then(loadProjects).then(populate).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
