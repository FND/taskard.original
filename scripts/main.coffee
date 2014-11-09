rivets = require("rivets")
Store = require("dav-dump")
Board = require("./board")
TaskForm = require("./task_form")
Repository = require("./repository")
util = require("./util")

repo = new Repository([basePath, "store"].join("/"), # XXX: hard-coded directory
		["to do", "in progress", "review pending", "done"]) # XXX: hard-coded
registry = {} # project stores -- TODO: obsolete due to `repo`
board = new Board(".board", repo.taskStates, registry)

onProjectLoad = (project, tasks) ->
	index = {}
	index[project] = tasks
	board.init(index) # TODO: s/init/add/

basePath = document.location.toString().split("/")[...-1].join("/")
repo.load(onProjectLoad).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
