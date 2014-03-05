// ==========================================================================
// Project:		Video - mainPage
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

// This page describes the main user interface for your application.	
Video.mainPage = SC.Page.design({

	// The main pane is made visible on screen as soon as your app is loaded.
	// Add childViews to this pane for views to display immediately on page 
	// load.
	mainPane: SC.MainPane.design({
		childViews: 'video_module'.w(),
		
		video_module: Video.VideoModule.design({
			layout: {left: 0, right: 0, top: 0, bottom: 0}
		})
	})

});
