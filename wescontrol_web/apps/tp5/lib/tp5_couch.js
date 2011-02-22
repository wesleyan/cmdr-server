// ==========================================================================
// Project:		Tp5.CouchDataSource
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Tp5 CouchDataSource */

/** @class

	(Document Your Data Source Here)

	@extends SC.DataSource
*/

sc_require('lib/couch');

Tp5.CouchDataSource = CouchDataSource.extend({
	appObject: Tp5,
	
	disableChangesBinding: "Tp5.appController.disableChanges",
	
	fetchedBuildingsCallback: function(response){
		Tp5.deviceController.refreshContent();
		//we break up the string in a funny manner so that it won't get replaced when we replace the
		//other one
    var compare_string = "REPLACE_WITH_REAL_MAC_THIS_SHOULD_BE_UNIQUE";
    
		if(Tp5.appController.mac.slice(0, compare_string.length) != compare_string)
		{
			var query = SC.Query.local(Tp5.Room, 'mac = {mac}', {mac: Tp5.appController.mac});
			
			Tp5.roomController.set('content', Tp5.store.find(query).firstObject());
		}
		else
		{
			console.log("Runing local dev mode");
			Tp5.roomController.set('content', Tp5.store.find(Tp5.Room, Tp5.appController.roomID));
		}
	},
	
	fetchedSourcesCallback: function(response){
		Tp5.sourceController.contentChanged();
	}
});
