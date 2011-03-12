// ==========================================================================
// Project:   Video.MouseHandlingFix
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  this is a mixin that fixes SC's built-in broken mouse handling

  @extends SC.Object
*/

Video.MouseHandlingFix = {
	
	//override this to get mouse events
	mouseClicked: function(){},
	
	mouseInside: NO,
		
	mouseDown: function(){
		return YES;
	},
	
	mouseUp: function(evt){		
		if(this.mouseInside)
		{
			this.mouseClicked(evt);
		}
		return YES;
	},
	
	mouseExited: function(evt) {
		this.set('mouseInside', NO);
		return YES;
	},
	
	mouseEntered: function(evt){
		this.set('mouseInside', YES);
		return YES;
	}
	
};