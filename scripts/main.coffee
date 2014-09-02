rivets = require("rivets")

data =
	"task-states": ["to do", "in progress", "under review", "done"]
	projects: ["foo", "bar"]

node = document.querySelector(".board")
rivets.bind(node, data)
