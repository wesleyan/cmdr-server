// ==========================================================================
// Project:		Video.CouchDataSource
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video CouchDataSource */

/** @class

	(Document Your Data Source Here)

	@extends SC.DataSource
*/

sc_require('lib/couch');

Video.CouchDataSource = CouchDataSource.extend({
	appObject: Video,
	
	disableChangesBinding: "Video.appController.disableChanges",
	
	fetchedBuildingsCallback: function(response){
		console.log("Fetched Buildings");
		Video.deviceController.refreshContent();
	},
	
	fetchedSourcesCallback: function(response){
		Video.sourceController.contentChanged();
	}
});
