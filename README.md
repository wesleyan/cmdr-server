# cmdr-devices

This repository contains all of the device drivers that have been written for cmdr thus far.

cmdr is split into three parts: [cmdr](https://github.com/wesleyan/cmdr) which contains the code 
for the daemon and the touch screen interface, 
[cmdr-server](https://github.com/wesleyan/cmdr-server) which holds
the backend/frontend code run on the central server, and the device drivers contained within this repo.

##Development notes
###Code style
All code should match the following style: spaces for indentation and for aligning 
and line lengths should be minimized but there is no hard cut-off. 
For Ruby code, class names ShouldBeCamelCased, variable and method names 
should\_be\_underscored, every method and class should be documented 
using [Yardoc](yardoc.com) tags and 
[markdown](http://daringfireball.net/projects/markdown) formatting 
and [RSpec](http://rspec.info) tests should be written for all functionality.

For Javascript, the same formatting rules should apply, but variable 
and method names shouldBeCamelCased as well as class names. Methods 
and classes should be documented using 
[JSDoc](http://usejsdoc.org). Also, all code should 
be run through [JSLint](http://www.jslint.com) and any errors it 
identifies should be corrected (this means no global variables 
and semi-colons are mandatory).

In general, try to maintain the style already found in the code.
