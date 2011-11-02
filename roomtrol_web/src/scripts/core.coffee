slinky_require('vendor/backbone.js')
slinky_require('vendor/handlebars.js')

window.App =
  debugging: on

  log: (args...) -> if @debugging then console.log.apply(console, args)

  modules: {}

