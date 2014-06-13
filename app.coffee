restify = require('restify')
mongoose = require('mongoose')
fs = require('fs')
config = require('./config/config')

mongoose.connect(config.db)
db = mongoose.connection;
db.on 'error', () ->
  throw new Error('unable to connect to database at ' + config.db)


modelsPath = __dirname + '/app/models'
fs.readdirSync(modelsPath).forEach (file) ->
  require(modelsPath + '/' + file) if file.indexOf('.coffee') >= 0

server = restify.createServer()

require('./config/restify')(server, config)
require('./config/routes')(server)
require('./config/jobs')(config)

server.listen(config.port)
