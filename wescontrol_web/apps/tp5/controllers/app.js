// ==========================================================================
// Project:   Tp5.appController
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Tp5 */

/** @class

  (Document Your Controller Here)

  @extends SC.Object
*/
Tp5.appController = SC.ObjectController.create(
/** @scope Tp5.appController.prototype */ {

	init: function() {
		this.clock = "";
		this._timer = SC.Timer.schedule({ 
			target: this, 
			action: 'tick', 
			repeats: YES, 
			interval: 1000
		});
	},
	
	// TODO: Add your own code here.
	now: function() {
		//return new SC.DateTime.create().toFormattedString("%I:%M %p");
		var meridian = "AM";
		if(new Date().getHours() >= 12)meridian = "PM";
		return new Date().format('h:mm') + " " + meridian; 
	},
	
	tick: function() {
		this.set('clock', this.now());
	},
	
	mac: 'REPLACE_WITH_REAL_MAC_THIS_SHOULD_BE_UNIQUE_e1599512ea6',
	
	roomID: '99b9b6d7bc4c69844b9b70ff601e3124',
	
	disableChanges: NO,
	
	projectorOverlayVisible: NO
	
}) ;
