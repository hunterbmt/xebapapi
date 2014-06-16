module.exports = (server) -> 
  movieApi = require '../app/api/movie'
  server.get '/movie', movieApi.fetch
  
