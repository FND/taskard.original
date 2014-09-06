# UI for creating/modifying individual tasks

rivets = require("rivets")

module.exports = class TaskForm
	constructor: (selector, @board, @registry) ->
		self = @
		@data =
			projects: []
			categories: ["", "urgent", "important", "casual"] # XXX: hard-coded
			onSubmit: (ev, rv) -> self.onSubmit.call(@, ev, rv, self) # XXX: hacky

		node = document.querySelector(selector)
		rivets.bind(node, @data)

	init: (projects) ->
		for project, tasks of projects
			@data.projects.push(project) # XXX: inefficient WRT Rivets re-rendering?

	onSubmit: (ev, rv, self) ->
		task =
			title: rv.task
			category: rv.selectedCategory
			state: self.board.states[0] # XXX: hard-coded -- XXX: tight coupling

		projects = this.parentNode.getElementsByClassName("radios")[0]. # XXX: should use Rivets for this
			getElementsByTagName("input")
		for radio in projects
			selectedProject = radio.value if radio.checked
		return unless selectedProject # TODO: user notification

		store = self.registry[selectedProject] # XXX: might not be populated yet
		store.add(task) # TODO: error handling -- TODO: UI updates

		ev.preventDefault()
