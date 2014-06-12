express = require('express')
mongoose = require('mongoose')
fs = require('fs')
config = require('./config/config')

mongoose.connect(config.db)
db = mongoose.connection;
db.on 'error', () ->
  throw new Error('unable to connect to database at ' + config.db)


modelsPath = __dirname + '/app/models'
fs.readdirSync(modelsPath).forEach (file) ->
  require(modelsPath + '/' + file) if file.indexOf('.js') >= 0

app = express()

require('./config/express')(app, config)
require('./config/routes')(app)
require('./config/jobs')(config)

app.listen(config.port)