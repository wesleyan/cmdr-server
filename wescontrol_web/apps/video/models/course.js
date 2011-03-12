// ==========================================================================
// Project:   Video.Course
// Copyright: ©2011 My Company, Inc.
// ==========================================================================
/*globals Video */

/** @class

  (Document your Model here)

  @extends SC.Record
  @version 0.1
*/
Video.Course = SC.Record.extend(
/** @scope Video.Course.prototype */ {

  name: SC.Record.attr(String),
  department: SC.Record.attr(String),
  number: SC.Record.attr(String),
  teacher: SC.Record.attr(String),

  listing: function() {
    return this.get('department') + " " + this.get('number');
  }.property("department", "number").cacheable()
  

}) ;
