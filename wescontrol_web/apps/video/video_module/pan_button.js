// ==========================================================================
// Project:   Video.PanButtonView
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document Your View Here)

  @extends SC.View
*/
sc_require('lib/mouse_handling');

Video.PanButtonView = SC.View.extend(Video.MouseHandlingFix,
/** @scope Video.ActionView.prototype */ {

	classNames: ['pan-button'],
	lastAction: null,
	currentAction: null,
	
	regions: [
		{
			action: "left",
			coords: [[77,77], [23, 23], [0,77], [23, 131]]
		},
		{
			action: "right",
			coords: [[77,77], [131,23], [170,75], [131,131]]
		},
		{
			action: "up",
			coords: [[77,77], [131, 23], [77,0], [23,23]]
		},
		{
			action: "down",
			coords: [[77,77], [131, 131], [77, 170], [23, 131]]
		}
	],
	
	pointInPolygon: function(poly, point){
		var x = point[0];
		var y = point[1];
		if(poly.shape == "circle")
		{
			return Math.pow(x-poly.center[0],2) + Math.pow(y - poly.center[1],2) < Math.pow(poly.radius,2);
		}
		else
		{
			var c, i, l, j;
			poly = poly.coords;
		    for(c = false, i = -1, l = poly.length, j = l - 1; ++i < l; j = i)
			{
				var test1 = (poly[i][1] <= y && y < poly[j][1]) || (poly[j][1] <= y && y < poly[i][1]);
				var test2 = x < (poly[j][0] - poly[i][0]) * (y - poly[i][1]) / (poly[j][1] - poly[i][1]) + poly[i][0];
		        if(test1 && test2)c = !c;
			}
		    return c;
		}
	},
		
	mouseDown: function(evt){
		if(evt.target.className.split(" ").some(function(x){return x == "pan-button";}))
		{
			//unfortunately, we have to use js to inspect the coordinates of the touch in order to see
			//which button was pressed. I wish there was a better way to do this, but there appears not
			//to be.			
			var x = evt.originalEvent.offsetX;
			var y = evt.originalEvent.offsetY;
			for(var i = 0; i < this.regions.get('length'); i++)
			{
				if(this.pointInPolygon(this.regions.objectAt(i), [x,y]))
				{
					SC.$('.pan-button')[0].className = "pan-button " + this.regions.objectAt(i).action;
					this.set('currentAction', this.getAction());
					break;
				}
				else {
					this.set('currentAction', null);
				}
			}
		}
	},
	
	mouseClicked: function(evt){
		if(SC.$('.pan-button')[0].className.split(" ").some(function(x){ return x != "pan-button'";}))
		{
			this.set('lastAction', this.getAction());
			this.set('currentAction', null);
			SC.$('.pan-button')[0].className = "pan-button";
		}
	},
	
	getAction: function(){
		return SC.$('.pan-button')[0].className.split(" ").find(function(x){
			return x != "pan-button";}
		);
	}
});
