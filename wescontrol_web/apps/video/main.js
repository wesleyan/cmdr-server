// ==========================================================================
// Project:   Video
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video*/

// This is the function that will start your app running.  The default
// implementation will load any fixtures you have created then instantiate
// your controllers and awake the elements on your page.
//
// As you develop your application you will probably want to override this.
// See comments for some pointers on what to do next.
//
Video.main = function main() {

	// Step 1: Instantiate Your Views
	// The default code here will make the mainPane for your application visible
	// on screen.  If you app gets any level of complexity, you will probably 
	// create multiple pages and panes.  
	Video.getPath('mainPage.mainPane').append() ;

	Video.store.find(Video.Building);
	
	var deviceQuery = SC.Query.local(Video.Device, 'belongs_to = {room_id}', {room_id: Video.appController.roomID});
	Video.deviceController.set('content', Video.store.find(deviceQuery));
  
  Video.courseController.set('content',
                             Video.store.find(Video.Course));

} ;

function main() { Video.main(); }
