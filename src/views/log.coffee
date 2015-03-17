class DefaultLogView extends Marionette.ItemView
	constructor: (data) ->
		data.template = Handlebars.templates['log-item-' + data.model.get('type')]
		super data

	serializeData: ->
		data = @model.toJSON()
		if not data.from 
			data.from = 'self'
			data.fromName = @options.parent.roomView.model.self.get('name')
		else
			data.fromName = @options.parent.roomView.getUserCollection().get(data.from).get('name')
		return data

class LogCollectionView extends Marionette.CollectionView
	typeViews: 
		'*': DefaultLogView

	constructor: (opts) ->
		super opts
		@roomView = opts.roomView

	getChildView: (model) -> @typeViews[model.get 'type'] ? @typeViews['*']
	childViewOptions: (model, index) => 
		parent: @

class LogView extends Marionette.LayoutView 
	template: Handlebars.templates['log-panel']
	regions:
		logs: '#logsList'

	events: 
		'keydown textarea#msgInput': "keyDown"

	constructor: (@roomView, opts) ->
		opts = opts ? {}
		opts.collection = @roomView.getLogCollection()
		super opts
	
	onRender: ->
		@logs.show new LogCollectionView
			collection: @collection
			roomView: @roomView

	sendMsg: ->
		v = @$el.find('#msgInput').val()
		@$el.find('#msgInput').val('')
		@roomView.sendMsg v

	keyDown: (e) ->
		if e.which == 13 and not e.ctrlKey
			e.preventDefault()
			@sendMsg()

module.exports = LogView