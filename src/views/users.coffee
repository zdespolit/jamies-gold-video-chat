class UserItemView extends Marionette.ItemView
	tagName: 'li'
	template: Handlebars.templates['user-item']
	modelEvents: 
		'change': 'render'
		'change:stream': 'renderAudioLevel'

	renderAudioLevel: () =>
		debugger

class UserCollectionView extends Marionette.CollectionView
	tagName: 'ul'
	childView: UserItemView

class UsersView extends Marionette.LayoutView
	regions: 
		users: '.usersList'
	template: Handlebars.templates['users-panel']
	constructor: (@roomView) ->
		super
			collection: @roomView.getUserCollection()

	onRender: ->
		@users.show new UserCollectionView
			collection: @collection

module.exports = UsersView