// ==========================================================================
// Project:   Tp5.video_module
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Tp5 */

/** @class

  (Document Your View Here)

  @extends SC.View
*/
sc_require('lib/mouse_handling');

Tp5.VideoModule = SC.View.extend(Tp5.MouseHandlingFix,
/** @scope Tp5.ActionView.prototype */ {

	classNames: ['video-module']
	
});
