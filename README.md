#Roomtrol Server
This repository holds the backend code for the central roomtrol server (responsible for managing all of the controllers), the web interface that runs on the server as well as the touchscreen interface run on the controllers (both of which are in the wescontrol_web subdirectory).

Roomtrol is split into three parts: the server code, [roomtrol-daemon](https://github.com/mwylde/roomtrol-daemon) which contains the code for the daemon that runs on each controller, and [roomtrol-devices](https://github.com/mwylde/roomtrol-devices) which holds the various device drivers that have been written.

##Development notes
###Code style
All code should match the following style: tabs for indentation and spaces for aligning and line lengths should be minized but there is no hard cut-off. For Ruby code, class names ShouldBeCamelCased, variable and method names should\_be\_underscored, every method and class should be documented using [Yardoc](yardoc.com) tags and [markdown](http://daringfireball.net/projects/markdown/) formatting and [RSpec](rpsec.org) tests should be written for all functionality.

For Javascript, the same formatting rules should apply, but variable and method names shouldBeCamelCased as well as class names. Methods and classes should be documented using [JSDoc](http://code.google.com/p/jsdoc-toolkit/). Also, all code should be run through [JSLint](http://www.jslint.com/) and any errors it identifies should be corrected (this means no global variables and semi-colons are mandatory).

In general, try to maintain the style already found in the code.

###Git usage
We are using [Git Flow](http://nvie.com/git-model) as described in that blog post. There is also [a tool](http://github.com/nvie/gitflow) that makes it easier to follow. The basic idea is that the master branch should only be used for tested and vetted releases. The normal development integration branch is develop, while features are staged in their own branches, which are named features/xxx. When a feature is finished, it is merged back into develop. When a number of features have been finished and it becomes prudent to release, you create a release branch from develop. The release branch is then heavily tested and any issues found are fixed. When considered production-ready, the release branch is merged into master, which is then tagged with the version number. This way, master is always stable and ready to be deployed, while you can have more freedom to break things in your feature branch and in develop.