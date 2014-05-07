#cmdr-server
This repository holds the backend code for the central cmdr server 
(responsible for managing all of the controllers) and the web 
interface that allows interaction with the server.

cmdr is split into three parts: the centralized server code contained within this repo, 
[cmdr](https://github.com/wesleyan/cmdr) which contains the 
code for the daemon that runs on each controller, and 
[cmdr-devices](https://github.com/wesleyan/cmdr-devices) which holds 
the various device drivers that have been written.

**Note: We use subtrees for the devices. More information can be found
[here](http://blogs.atlassian.com/2013/05/alternatives-to-git-submodule-git-subtree)**

## Running cmdr-server
Running cmdr-server is a bit involved at the moment as there are
three different pieces that need to be invoked separately, in addition
to CouchDB.

### Proxy server
Start the proxy server by running `bin/cmdr-server` in the root
directory. To run a local instance, run `bin/run-locally` instead.

### Slinky
For the website to actually display anything, you need to 
run `slinky start` inside cmdr_web/src.

##Development notes
###Code style
All code should match the following style: spaces for indentation and 
aligning and line lengths should be minimized but there is no hard cut-off. 
For Ruby code, class names ShouldBeCamelCased, variable and method names 
should\_be\_underscored, every method and class should be documented 
using [Yardoc](http://yardoc.com) tags and 
[markdown](http://daringfireball.net/projects/markdown) formatting 
and [RSpec](http://rspec.info) tests should be written for all functionality.

For Javascript, the same formatting rules should apply, but variable 
and method names shouldBeCamelCased as well as class names. Methods 
and classes should be documented using 
[JSDoc](http://usejsdoc.org). Also, all code 
should be run through [JSLint](http://www.jslint.com) and any errors 
it identifies should be corrected (this means no global variables 
and semi-colons are mandatory).

In general, try to maintain the style already found in the code.

###Git usage
We are using [Git Flow](http://nvie.com/git-model) as described in that blog post. 
There is also [a tool](http://github.com/nvie/gitflow) that makes it easier 
to follow. The basic idea is that the master branch should only be used 
for tested and vetted releases. The normal development integration branch 
is develop, while features are staged in their own branches, which are named 
features/xxx. When a feature is finished, it is merged back into develop. 
When a number of features have been finished and it becomes prudent to release, 
you create a release branch from develop. The release branch is then heavily 
tested and any issues found are fixed. When considered production-ready, 
the release branch is merged into master, which is then tagged with the 
version number. This way, master is always stable and ready to be deployed, 
while you can have more freedom to break things in your feature branch and in develop.

##License
cmdr-server is licensed under the [Apache License](https://raw.github.com/wesleyan/cmdr-server/master/LICENSE).

