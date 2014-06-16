'use strict';
querystring = require('querystring')
request = require('request')
Q = require('q')
_ = require('lodash-node')
yifyApiEndpoint = 'https://yts.re/api/list.json?'

queryTorrents = (filters) ->
    deferred = Q.defer()
    params =
      sort : 'seeds'
      limit: '50'
    params.keywords = filters.keywords.replace(/\s/g, '% ') if filters.keywords
    params.genre = filters.genre if filters.genre
    params.order = filters.order if filters.order
    params.sort = filters.sort if filters.sort
    params.set = filters.set if filters.set
    url = yifyApiEndpoint + querystring.stringify(params).replace(/%E2%80%99/g, '%27')
    request {url: url, json: true}, (error, response, data) ->
      if error
        deferred.reject(error)
      else
        if !data or (data.error and data.error is not 'No movies found')
          err = if data then data.error else 'No data returned'
          deferred.reject(err) ;
        else
          deferred.resolve(data.MovieList || []) ;

    deferred.promise

formatResult = (results) ->
  movies = {} ;
  console.log(results.length)
  _.each results, (item) ->
      return if item.Quality is '3D'
      largeCover = item.CoverImage.replace(/_med\./, '_large.')

      seeds = item.TorrentSeeds;
      peers = item.TorrentPeers;

      torrents = {} ;
      torrents[item.Quality] =
        url: item.TorrentMagnetUrl,
        size: item.SizeByte,
        seeds: seeds,
        peers: peers

      movie = movies[item.ImdbCode];
      if not movie
        movie =
          imdbCode: item.ImdbCode
          title: item.MovieTitleClean.replace(/\([^)]*\)|1080p|DIRECTORS CUT|EXTENDED|UNRATED|3D|[()]/g, '')
          publicYear: item.MovieYear
          rating: item.MovieRating
          images:
            cover: largeCover
          torrents: torrents
          imdbLink: item.ImdbLink
          seeds:seeds
          date: item.DateUploaded
      else
        _.extend(movie.torrents, torrents) ;

      movies[item.ImdbCode] = movie;
  _.values(movies)

module.exports.fetch = (filters) ->
  queryTorrents(filters).then(formatResult)

module.exports.extractImdbs = (movies) ->
  _.pluck(movies, 'imdbCode')
