express = require('express')
compression = require('compression')
logger = require('morgan')
favicon = require('serve-favicon')
bodyParser = require('body-parser')
methodOverride = require('method-override')
errorHandler = require('errorhandler')

module.exports = (app, config) ->
  app.use compression()
  app.use express.static(config.root + '/public')
  app.set 'port', config.port
  app.set 'views', config.root + '/app/views'
  app.set 'view engine', 'jade'
  app.use favicon(config.root + '/public/img/favicon.ico')
  app.use logger('dev')
  app.use bodyParser()
  app.use methodOverride()
  app.use errorHandler()

