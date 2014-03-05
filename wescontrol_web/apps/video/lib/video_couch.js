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
	},

  fetch: function(store, query) {
    if(query.recordType == Video.Course){
      console.log("Fetching course");
      SC.Request.getUrl('/videos/_design/Course/_view/by_courses').json()
        .notify(this, 'didFetchCourses', store, query)
        .send();
      return YES;
    }
    // pass to parent definitions
    return sc_super();
  },

  didFetchCourses: function(response, store, query){
    if(SC.ok(response)){
      var courses = [];
      response.get('body').rows.forEach(function(row){
        var course = {
          guid: row.value._id,
          name: row.value.name,
          department: row.value.department,
          number: row.value.number,
          teacher: row.value.teacher
        }
        courses.push(course);
      });
      store.loadRecords(Video.Course, courses);
      store.dataSourceDidFetchQuery(query);
    }
  }
});
