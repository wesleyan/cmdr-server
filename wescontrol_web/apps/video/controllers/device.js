// ==========================================================================
// Project:   Video.deviceController
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document Your Controller Here)

  @extends SC.Object
*/
Video.deviceController = SC.ArrayController.create(
/** @scope Tp5.deviceController.prototype */ {

	contentChanged: function() {
		
		var devices = {};
		console.log("Setting devices on %d", this.get('content').get('length'));
		this.get('content').forEach(function(device){
			console.log("Adding %s", device.get('name'));
			devices[device.get('name')] = device;
		});
		
		this.devices = devices;
		
	},
	
	refreshContent: function() {
		this.set('content', Video.store.find(Video.Device));
		console.log(Video.deviceController.get('content').mapProperty("name"));
		this.contentChanged();
		console.log(Video.deviceController.get('content').mapProperty("name"));
	}
}) ;
