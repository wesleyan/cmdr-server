// ==========================================================================
// Project:   Video.ZoomControlView
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video sprintf */

/** @class

  (Document Your View Here)

  @extends SC.View
*/

Video.ZoomControlView = SC.View.extend(
/** @scope Video.ZoomControlView.prototype */{
	classNames: ['zoom-control'],

	childViews: "zoomSlider".w(),
	
	zoomOffset: 0.0,
	command: "zoom_stop",
	
	zoomOffsetChanged: function(){
		this.set('command', this.zoomOffset > 0.1 ? "zoom_in" :
			this.zoomOffset < -0.1 ? "zoom_out" : "zoom_stop");
	}.observes('zoomOffset'),

	zoomSlider: SC.View.design(SC.Animatable, {
		layout: {height: 164, width: 122, bottom: 0, centerX: -2},
		classNames: ["zoom-slider"],
		
		didCreateLayer: function(){
			sc_super();
	
			this.updateTimer = SC.Timer.schedule({
				interval: 5000,
				target: this,
				action: "updateZoom",
				repeating: YES
			});
			
			this.$()[0].style.backgroundPositionY = "50%";
		},

		transitions: {
			backgroundPositionY: {duration: 0.25, timing: SC.Animatable.TRANSITION_CSS_EASE_IN}
		},

		dragging: NO,

		mouseDown: function(){
			this.set('dragging', YES);
			this.updateTimer.invalidate();
			//Video.appController.set('disableChanges', YES);
		},

		mouseUp: function(){
			this.set('dragging', NO);
			this.set("style", {backgroundPositionY: "50%"});
			this.$()[0].style.backgroundPositionY = "50%";
			this.parentView.set('zoomOffset', 0.0);
			//Video.appController.set('disableChanges', NO);
		},

		mouseMoved: function(evt){
			if(this.dragging)
			{
				var h = 160-evt.target.offsetTop; //height of the draggable area; found empirically
				var percent = (evt.clientY-350-evt.target.offsetTop)/h;
				if(percent < -0.05)percent = -0.05;
				if(percent > 1)percent = 1;
				this.$()[0].style.backgroundPositionY = sprintf("%.1f%%", percent*100);
				this.parentView.set('zoomOffset', (0.5-percent)*2);
				//Video.volumeController.set_volume(1-percent);
			}
		}
	})
});
