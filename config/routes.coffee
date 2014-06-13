module.exports = (server) -> 
  user = require '../app/api/user'
  server.get '/', user.getAll
  
