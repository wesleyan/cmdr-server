// ==========================================================================
// Project:   Video.ZoomControlView
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video sprintf */

/** @class

  (Document Your View Here)

  @extends SC.View
*/

Video.ZoomControlView = SC.View.extend(SC.Animatable,
/** @scope Video.ZoomControlView.prototype */{
	classNames: ['zoom-control'],

	childViews: "zoomSlider".w(),

	zoomSlider: SC.View.design({
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
		},

		transitions: {
			backgroundPositionY: {duration: 0.25}
		},

		dragging: NO,

		updateZoom: function(){
			//Video.log("Updating volume: %f", Video.volumeController.volume);
			//Video.log("Setting to %s", sprintf("%.0f%%", Video.volumeController.volume*100));
			//Video.volumeController.updateLastVolumeSet();
			//this.$()[0].style.backgroundPositionY = sprintf("%.0f%%", 100-Video.volumeController.volume*100);
			//this.set("style", {backgroundPositionY: sprintf("%.0f%%", Tp5.volumeController.volume*100)});
		},

		mouseDown: function(){
			this.set('dragging', YES);
			this.updateTimer.invalidate();
			//Video.appController.set('disableChanges', YES);
		},

		mouseUp: function(){
			this.set('dragging', NO);
			this.updateTimer = SC.Timer.schedule({
				interval: 500,
				target: this,
				action: "updateVolume",
				repeating: YES
			});
			//Video.appController.set('disableChanges', NO);
		},

		mouseMoved: function(evt){
			if(this.dragging)
			{
				var h = evt.target.offsetHeight-36; //height of the draggable area; 36 found empirically
				var percent = (evt.clientY-evt.target.offsetTop-27)/h;
				if(percent < 0)percent = 0;
				if(percent > 1)percent = 1;
				SC.CoreQuery.find(".zoom-slider")[0].style.backgroundPositionY = sprintf("%.1f%%", percent*100);
				//Video.volumeController.set_volume(1-percent);
			}
		}
	})
});
