path = require('path')
rootPath = path.normalize(__dirname + '/..')
env = process.env.NODE_ENV || 'development'

config =
  development:
    root: rootPath
    app: 
      name: 'xebapapi'
    port: 3000
    db: 'mongodb://localhost/xebapapi-development'

  test: 
    root: rootPath
    app: 
      name: 'xebapapi'
    port: 3000
    db: 'mongodb://localhost/xebapapi-test'

  production:
    root: rootPath
    app:
      name: 'xebapapi'
    port: 3000
    db: 'mongodb://localhost/xebapapi-production'

module.exports = config[env];
