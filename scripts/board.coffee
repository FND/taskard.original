# UI for managing tasks organized by project and state

rivets = require("rivets")
Sortable = require("sortable")
Store = require("./store")

module.exports = class Board
	# `selector` identifies the respective container element
	# `states` is an array of task states (strings) -- TODO: derive from tasks (=> order?)
	# `registry` is an index of project stores
	constructor: (selector, @states, @registry) ->
		@matrix = []
		@root = document.querySelector(".board")
		rivets.bind(@root, @)

	# `tasksByProject` is an object of the form `{ project: { title: item } }`
	init: (tasksByProject) ->
		for project, tasks of tasksByProject
			index = {} # tasks by state
			for title, item of tasks
				task = new Task(title, item.state, item.category, item.body)
				index[item.state] ?= []
				index[item.state].push(task)

			project = new Project(project, (index[state] for state in @states))
			@matrix.push(project) # XXX: inefficient WRT Rivets re-rendering?

		dragndrop =
			group: ".tasks"
			draggable: "li" # XXX: bad selector
			ghostClass: "placeholder"
			onRemove: @onDropRemove
			onAdd: @onDropAdd
			# TODO: `onUpdate` for internal ordering
			onEnd: @onDropEnd
		for list in @root.querySelectorAll(".tasks") # TODO: use event delegation!?
			new Sortable(list, dragndrop)

	onTaskDelete: (ev, rv) =>
		store = @registry[rv.project.title]
		store.delete(rv.task.title). # TODO: error handling
			then(=> # XXX: breaks encapsulation; should use Rivets for UI updates
				node = this.parentNode
				node.parentNode.removeChild(node))

	onDropRemove: (ev) =>
		@dropRemove = @determineTask(ev.item, ev.target)

	onDropAdd: (ev) =>
		@dropAdd = @determineTask(ev.item)

	onDropEnd: (ev) =>
		if @dropAdd and @dropRemove # moved between projects
			source = @registry[@dropRemove.project]
			target = @registry[@dropAdd.project]
			source.move(@dropRemove.title, target)

		delete @dropAdd
		delete @dropRemove

	determineTask: (node, list, includeState) =>
		list ?= node.parentNode # XXX: breaks encapsulation
		task =
			title: node.getAttribute("data-task")
			project: list.getAttribute("data-project")

		return task unless includeState

		sibling = list
		index = 0
		while(sibling)
			sibling = sibling.previousSibling
			index++ if sibling?.classList?.contains("tasks")
		task.state = @states[index] # XXX: breaks encapsulation, kinda

		return task

class Project
	constructor: (@title, @tasks) ->

class Task
	constructor: (@title, @state, @category = "", @body) ->
