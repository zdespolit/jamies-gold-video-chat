WildEmitter = require 'wildemitter'
IDBWriter = require './writers/idbwriter.coffee' 

class RecordingController extends WildEmitter
	constructor: (@room, @collection, config={}) ->
		super
		defaults = 
			recordingPeriod: 1000
		@config = _.extend {}, defaults, config
		@writer = config?.writer ? new IDBWriter 'fireside-000-0'
		@writer.open()

	addStream: (stream) ->
		if MediaRecorder?
			@mediaRecorder = new MediaRecorder stream
			@mediaRecorder.ondataavailable = (e) => @saveRecording(e.data)
			@switchState 'ready'

    
	switchState: (state, beforeSwitch) =>
		unless state == @status
			beforeSwitch && beforeSwitch.call(@)
			@status = state
			if state == 'started' || state == 'stopped'
				@currentRecording.set state, new Date
			@emit state, @currentRecording

	saveRecording: (blob) => 
		# console.log "got blob,", blob.size
		file = @writer.getFile @currentRecording.id
		file.writeBlob(blob).then ->
			# console.log "wrote", blob.size
		@currentRecording.set 'filesize', @currentRecording.get 'filesize' + blob.size		
		@currentRecording.save()

	start: ->
		if not @mediaRecorder?
			throw new Error('No stream set up yet.')
		@switchState 'started', () ->
			@currentRecording = @collection.create()
			@mediaRecorder.start(@config.recordingPeriod)

	stop: ->
		@switchState 'stopped', () =>
			@mediaRecorder.stop()
			@emit('recordReady', @currentRecording)

module.exports = RecordingController