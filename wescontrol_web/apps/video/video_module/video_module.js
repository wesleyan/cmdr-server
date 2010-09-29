// ==========================================================================
// Project:   Video.video_module
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document Your View Here)

  @extends SC.View
*/
sc_require('lib/mouse_handling');
sc_require('video_module/zoom_control');

Video.VideoModule = SC.View.extend(Video.MouseHandlingFix,
/** @scope Tp5.ActionView.prototype */ {

	classNames: ['video-module'],
	
	childViews: 'pan zoom'.w(),
	
	pan: SC.View.design({
		classNames: ['pan-controls'],
		layout: {left: 45, top: 45, height: 210, width: 157},
		childViews: 'pan_label pan_control'.w(),
		
		pan_label: SC.LabelView.design({
			layout: {centerX: 0, top: 0, width: 64, height: 35},
			value: 'Pan'
		}).classNames('title'),
		
		pan_control: Video.PanButtonView.design({
			layout: {centerX: 0, width: 157, top: 45, height: 162}
		})
	}),
	
	zoom: SC.View.design({
		classNames: ['zoom-controls'],
		layout: {left: 45, top: 300, height: 210, width: 157},
		childViews: 'zoom_label zoom_control'.w(),
		
		zoom_label: SC.LabelView.design({
			layout: {centerX: 0, top: 0, width: 90, height: 35},
			value: 'Zoom'
		}).classNames('title'),
		
		zoom_control: Video.ZoomControlView.design({
			layout: {centerX: 0, width: 50, top: 45, height: 162}
		})
	})
	
	
});
