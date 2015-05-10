RecordingController = require './recording_controller.coffee'
webrtc = require 'webrtcsupport'

class AudioRecordingController extends RecordingController
	constructor: (roomId) ->
		super

	addStream: (stream) =>
		audioContext = new webrtc.AudioContext()
		audioSourceNode = audioContext.createMediaStreamSource stream		
		@audioRecorder = new AudioRecorder audioSourceNode
		@switchState 'ready'

	start: =>
		@switchState 'started', () =>
			@currentRecording = @collection.create()
			@audioRecorder.start()

	stop: =>
		before = () =>
			@audioRecorder.stop()
			@audioRecorder.exportWAV (blob) =>				
				@saveRecording(blob)
				@emit('stopped', @currentRecording)

		@switchState 'stopped', before, true
			
module.exports = AudioRecordingController