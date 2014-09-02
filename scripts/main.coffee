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

store = new Store(storePath())
store.index().then((index) -> console.log(index)).
	catch((err) -> console.log("ERROR", err, err.stack)) # TODO: error handling
