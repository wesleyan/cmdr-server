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
sc_require('video_module/button');

Video.VideoModule = SC.View.extend(Video.MouseHandlingFix,
/** @scope Tp5.ActionView.prototype */ {

	classNames: ['video-module'],
	childViews: 'controls video_display'.w(),

	controls: SC.View.design({
		layout: {left: 0, top: 0, bottom: 0, width: 200},
		childViews: 'pan zoom record'.w(),
	
		pan: SC.View.design({
			classNames: ['pan-controls'],
			layout: {left: 45, top: 45, height: 210, width: 157},
			childViews: 'pan_label pan_control'.w(),
		
			pan_label: SC.LabelView.design({
				layout: {centerX: 0, top: 0, width: 64, height: 35},
				value: 'Pan'
			}).classNames('title'),
		
			pan_control: Video.PanButtonView.design({
				layout: {centerX: 0, width: 157, top: 45, height: 162},
				onCurrentActionChanged: function(){
					var command = "move_stop";
					if(this.get("currentAction")){
						command = "move_" + this.get("currentAction");
					}
					if(Video.deviceController.get('devices').camera){
						console.log("Sending command");
						Video.deviceController.get('devices').camera.send_command(command, [0.4, 0.4]);
					}
				}.observes("currentAction")
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
				layout: {centerX: 0, width: 157, top: 45, height: 168}
			})
		}),
	
		record: SC.View.design({
			classNames: ['record-control'],
			layout: {left: 45, top: 570, height: 140, width: 157},
			childViews: 'record_label record_button'.w(),
		
			record_label: SC.LabelView.design({
				layout: {centerX: 0, top: 0, width: 115, height:35},
				value: 'Record'
			}).classNames('title'),
		
			record_button: Video.ButtonView.design({
				layout: {centerX: 0, top: 45, height: 95, width: 95},
				classNames: 'record-button'.w()
			})
		})
	
	}),
	
	video_display: SC.View.design({
		layout: {left: 240, right: 30, top: 0, bottom: 0},
		childViews: "video_window bottom_controls".w(),
		
		video_window: SC.View.design({
			layout: {left: 0, right: 0, top: 30, bottom: 160}
		}).classNames('video-window'),
		
		bottom_controls: SC.View.design({
			layout: {left: 0, right: 0, height: 160, bottom: 0},
			childViews: "timecode_counter".w(),
			timecode_counter: SC.View.design({
				classNames: ['timecode-counter'],
				layout: {centerX: 0, width: 280, height: 80, centerY: 0},
				childViews: "label".w(),
				
				label: SC.LabelView.design({
					layout: {left: 0, right: 0, centerY: 0, height: 80},
					value: "00:21:23",
					textAlign: SC.ALIGN_CENTER
				})
			})
		})
	})
	
	
});
