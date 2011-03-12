// ==========================================================================
// Project:   Video.Building
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document your Model here)

  @extends SC.Record
  @version 0.1
*/
Video.Building = SC.Record.extend(
/** @scope Video.Building.prototype */ {
	rooms: SC.Record.toMany("WescontrolWeb.Room", {
		inverse: "building", isMaster: NO
	})
});
