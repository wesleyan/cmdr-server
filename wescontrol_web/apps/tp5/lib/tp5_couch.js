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
		if(Tp5.appController.mac != "REPLACE_WITH_REAL_MAC" + "_THIS_SHOULD_BE_UNIQUE_e1599512ea6")
		{
			var query = SC.Query.local(Tp5.Room, 'mac_address = {mac}', {mac: Tp5.appController.mac});
			
			Tp5.roomController.set('content', Tp5.store.find(query));
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
