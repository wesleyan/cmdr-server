// ==========================================================================
// Project:   Tp5.ZoomControlView
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Tp5 sprintf */

/** @class

  (Document Your View Here)

  @extends SC.View
*/

Tp5.ZoomControlView = SC.View.extend(
/** @scope Tp5.ZoomControlView.prototype */{
	classNames: ['zoom-control'],

	childViews: "zoomSlider".w(),

	zoomSlider: SC.View.design({
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
		layout: {height: 312, width: 50, bottom: 55, centerX: -2},

		transitions: {
			backgroundPositionY: {duration: 0.25}
		},

		dragging: NO,

		updateZoom: function(){
			//Tp5.log("Updating volume: %f", Tp5.volumeController.volume);
			Tp5.log("Setting to %s", sprintf("%.0f%%", Tp5.volumeController.volume*100));
			Tp5.volumeController.updateLastVolumeSet();
			this.$()[0].style.backgroundPositionY = sprintf("%.0f%%", 100-Tp5.volumeController.volume*100);
			//this.set("style", {backgroundPositionY: sprintf("%.0f%%", Tp5.volumeController.volume*100)});
		},

		mouseDown: function(){
			this.set('dragging', YES);
			this.updateTimer.invalidate();
			Tp5.appController.set('disableChanges', YES);
		},

		mouseUp: function(){
			this.set('dragging', NO);
			this.updateTimer = SC.Timer.schedule({
				interval: 500,
				target: this,
				action: "updateVolume",
				repeating: YES
			});
			Tp5.appController.set('disableChanges', NO);
		},

		mouseMoved: function(evt){
			if(this.dragging)
			{
				var h = evt.target.offsetHeight-36; //height of the draggable area; 36 found empirically
				var percent = (evt.clientY-evt.target.offsetTop-27)/h;
				if(percent < 0)percent = 0;
				if(percent > 1)percent = 1;
				SC.CoreQuery.find(".volume-slider")[0].style.backgroundPositionY = sprintf("%.1f%%", percent*100);
				Tp5.volumeController.set_volume(1-percent);
			}
		}
	})
});
