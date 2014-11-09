rivets = require("rivets")
Store = require("dav-dump")
Board = require("./board")
TaskForm = require("./task_form")
Repository = require("./repository")
util = require("./util")

registry = {} # project stores
board = new Board(".board", ["to do", "in progress", "review pending", "done"],
		registry)

onProjectLoad = (project, tasks) ->
	index = {}
	index[project] = tasks
	board.init(index) # TODO: s/init/add/

basePath = document.location.toString().split("/")[...-1].join("/")
repo = new Repository([basePath, "store"].join("/")) # XXX: hard-coded directory
repo.load(onProjectLoad).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
