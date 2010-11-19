// ==========================================================================
// Project:   Video.videoController
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video p */

/** @class

  (Document Your Controller Here)

  @extends SC.Object
*/
Video.videoController = SC.ObjectController.create(
/** @scope Video.videoController.prototype */ {
	camera: null,
	recorder: null,
	
	state: null,
	recordingStarted: null,
	
	updateDevices: function(){
		console.log("Updating asdf;lkjasd");
		if(Video.deviceController.get('devices'))
		{
			var devices = Video.deviceController.get('devices');
			if(devices)
			{
				this.set('camera', devices.camera);
				this.set('recorder', devices.recorder);
			}
		}
	}.observes('Video.deviceController.devices'),
	
	
	onRecordingChanged: function(){
		console.log("Recorder state update");
		var states = this.recorder.get('states');
		if(states){
			this.set('state', states.state);
			this.set('recordingStarted', states.recording_started);
		}
	}.observes("Video.videoController.recorder.state_vars")
	
	
}) ;
