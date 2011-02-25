// ==========================================================================
// Project:   Video.courseController
// Copyright: ©2011 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document Your Controller Here)

  @extends SC.Object
*/
Video.courseController = SC.ArrayController.create(
/** @scope Video.courseController.prototype */ {
  allowsEmptySelection: NO,

  selectionChanged: function(){
    if(Video.videoController.recorder){
      console.log("Selection: %s", this.get('selection').firstObject().get('guid'));
      Video.videoController.recorder.set_var("course", 
        this.get('selection').firstObject().get('guid'));
    }
  }.observes('selection')
}) ;
