rivets = require("rivets")
Store = require("dav-dump")
Board = require("./board")
TaskForm = require("./task_form")
Repository = require("./repository")
util = require("./util")

repo = new Repository([basePath, "store"].join("/"), # XXX: hard-coded directory
		["to do", "in progress", "review pending", "done"]) # XXX: hard-coded
board = new Board(".board", repo.taskStates)

onProjectLoad = (projectName, tasks, store) -> # XXX: `tasks` is kind of redundant
	board.add(projectName, tasks, store)

basePath = document.location.toString().split("/")[...-1].join("/")
repo.load(onProjectLoad).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
