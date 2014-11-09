rivets = require("rivets")
Store = require("dav-dump")
Board = require("./board")
TaskForm = require("./task_form")
Repository = require("./repository")
util = require("./util")

registry = {} # project stores
board = new Board(".board", ["to do", "in progress", "review pending", "done"],
		registry)
form = new TaskForm("form.task", board, registry)

initUI = (projectStores) -> # TODO: make UI widgets use `Store`s directly
	tasks = Object.keys(projectStores).
		map((project) -> projectStores[project].all().
				then((tasks) -> Promise.resolve([project, tasks])))
	Promise.all(tasks).
		then((tasksByProject) ->
			index = {}
			for [project, tasks] in tasksByProject
				index[project] = tasks
			board.init(index)
			form.init(index)
			return)

basePath = document.location.toString().split("/")[...-1].join("/")
repo = new Repository([basePath, "store"].join("/")) # XXX: hard-coded directory
repo.projects.
	then(initUI).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
