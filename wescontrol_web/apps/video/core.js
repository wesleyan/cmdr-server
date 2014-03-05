// ==========================================================================
// Project:   Video
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video p */

/** @namespace

  My cool new app.  Describe your application.
  
  @extends SC.Object
*/
Video = SC.Application.create(
	/** @scope Video.prototype */ {

	NAMESPACE: 'Video',
	VERSION: '0.1.0',

	// This is your application store.  You will use this store to access all
	// of your model data.  You can also set a data source on this store to
	// connect to a backend server.  The default setup below connects the store
	// to any fixtures you define.
	store: SC.Store.create().from('Video.CouchDataSource'),

	// TODO: Add global constants or singleton objects needed by your app here.
	debugging: YES,
	
	log: function(){
		if(this.debugging)console.log.apply(console, arguments);
	}

}) ;

p = function(path){
	return SC.objectForPropertyPath(path);
};

function screenSize() {
  console.log("ScreenSize");
  var html = document.documentElement;

	var w = window.outerWidth || html.clientWidth;
	
	// remove earlier widths
	html.className = html.className.replace(/ (w|lt)-\d+/g, "");
	
  var klass = [];
	var conf = {
			screens: [320, 480, 640, 768, 1024, 1280, 1440, 1680, 1920],
			section: "-section",
			page: "-page",
			head: "head"
		 };

	// add new ones
	klass.push("w-" + Math.round(w / 100) * 100);
	
	conf.screens.forEach(function(width) {
		if (w <= width) { klass.push("lt-" + width); } 
	});

  html.className += ' ' + klass.join( ' ' );
}

jQuery(document).ready(function(){
  console.log("Ready");
  screenSize();
})
