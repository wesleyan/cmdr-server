slinky_require('vendor/backbone.js')
slinky_require('vendor/backbone-relational.js')
slinky_require('vendor/handlebars.js')
slinky_require('vendor/backbone.modelbinding.js')

window.App =
  debugging: on

  log: (args...) -> if @debugging then console.log.apply(console, args)

  modules: {}

