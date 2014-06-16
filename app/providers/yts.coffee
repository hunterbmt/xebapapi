'use strict';
querystring = require('querystring')
request = require('request')
Q = require('q')
_ = require('lodash-node')
yifyApiEndpoint = 'https://yts.re/api/list.json?'


queryTorrents = (filters) ->
    deferred = Q.defer()
		params = 
      sort :'seeds'
      limit: '50'
    params.keywords = filters.keywords.replace(/\s/g, '% ') if filters.keywords
    params.genre = filters.genre if filters.genre
    params.order = filters.order if filters.order
    params.sort = filters.sorter if filters.sorter
    params.set = filters.page if filters.page
		url = yifyApiEndpoint + querystring.stringify(params).replace(/%E2%80%99/g,'%27');
    request {url: url, json: true}, (error, response, data) ->
      if error
        deferred.reject(error)
      else 
        if !data or (data.error and data.error !== 'No movies found')
          err = data? data.error: 'No data returned';
          deferred.reject(err);
        else 
          deferred.resolve(data.MovieList || []);

      deferred.promise

formatResult = (result) ->
  movies = {};
  _.each(items, function(movie) {
      return if movie.Quality === '3D'
      largeCover = movie.CoverImage.replace(/_med\./, '_large.');
            // Calc torrent health
      seeds = movie.TorrentSeeds;
      peers = movie.TorrentPeers;

      torrents = {};
      torrents[movie.Quality] =
        url: movie.TorrentUrl,
        size: movie.SizeByte,
        seed: seeds,
        peer: peers

      movie = movies[movie.imdbCode];
      if !movie
        movie =
          imdbCode: movie.imdbCode,
          title: movie.MovieTitleClean.replace(/\([^)]*\)|1080p|DIRECTORS CUT|EXTENDED|UNRATED|3D|[()]/g, ''),
          publicYear: movie.MovieYear,
          rating: movie.MovieRating,
          images:
            cover:largeCover
          torrents: torrents
      else 
        _.extend(movie.torrents, torrents);

      movies[movie.imdbCode] = movie;

  _.values(movies)

module.exports.fetch = (filter) ->
    queryTorrents(filters).then(formatResult)

module.exports.extractImdbs = (movies) ->
  _.pluck(movies, 'imdbCode');
