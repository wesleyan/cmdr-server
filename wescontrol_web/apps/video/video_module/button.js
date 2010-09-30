// ==========================================================================
// Project:   Video.ButtonView
// Copyright: ©2010 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document Your View Here)

  @extends SC.View
*/
sc_require('lib/mouse_handling');

Video.ButtonView = SC.View.extend(Video.MouseHandlingFix,
/** @scope Tp5.ButtonView.prototype */ {

	classNames: ["overflow"],

	mouseClicked: function(){
		if(this.disableStates.indexOf(this.state) == -1)
		{
			this.action();
		}
	},

	action: function(){
		//override this to do something
	},

	//add states to this to disable the button on those states
	disableStates: [],

	displayProperties: 'state value'.w(),

	render: function(context, firstTime) {
		context = context.begin('div').addClass('control-button');
		if(this.disableStates.indexOf(this.state) != -1)context.addClass('disabled');
		context = context.begin('div').addClass('label').push(this.value).end().end();
	}

});
