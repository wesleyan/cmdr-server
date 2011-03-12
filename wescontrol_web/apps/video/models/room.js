// ==========================================================================
// Project:   Video.Room
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document your Model here)

  @extends SC.Record
  @version 0.1
*/
Video.Room = SC.Record.extend(
/** @scope Video.Room.prototype */ {

	name: SC.Record.attr(String),
	building: SC.Record.toOne("WescontrolWeb.Building", {
		inverse: "rooms", isMaster: YES
	}),
	
	buildingName: function(){
		return this.getPath('building.name');
	}.property('building').cacheable(),
	
	fullName: function(){
		return this.getEach('buildingName', 'name').compact().join(' ');
	}.property('building', 'name').cacheable(),
	
	devices: SC.Record.toMany("WescontrolWeb.Device", {
		inverse: "room", isMaster: YES
	})

}) ;
