'use strict';
request = require('request')
Q = require('q')
URI = require('URIjs')
_ = require('lodash-node')

API_ENDPOINT = URI('http://api.trakt.tv/')
MOVIE_PATH = 'movie'
SHOW_PATH = 'show'
API_KEY = '515a27ba95fbd83f20690e5c22bceaff0dfbde7c'


querySummaries = (imdbIds) ->
    return if _.isEmpty(imdbIds)
    
    deferred = Q.defer()
    uri = API_ENDPOINT.clone()
        .segment [
            MOVIE_PATH,
            'summaries.json',
            API_KEY,
            imdbIds.join(','),
            'full'
        ]

    request {url: uri.toString(), json: true}, (error, response, data) ->
        if (error or !data)
            deferred.reject(error)
        else
            deferred.resolve(data);

    deferred.promise

resizeImage = (imageUrl, width) ->
    uri = URI(imageUrl)
    ext = uri.suffix()
    file = uri.filename().split('.' + ext)[0]

    uri.filename(file + '-' + width + '.' + ext).toString()

formatResult = (items) ->
    movies = {};
    _.each items, (movie) ->
        imdb = movie.imdb_id.replace('tt','');
        movie.image = resizeImage(movie.images.poster, '300');
        movie.bigImage = movie.images.poster;
        movie.backdrop = resizeImage(movie.images.fanart, '940');
        movies[imdb] = movie;
    movies;


episodeDetail = (data) {
    deferred = Q.defer()
    slug = data.title.toLowerCase()
        .replace(/[^\w ]+/g,'')
        .replace(/ +/g,'-')

    uri = API_ENDPOINT.clone()
        .segment [
            SHOW_PATH,
            'episode',
            'summary.json',
            API_KEY,
            slug,
            data.season.toString(),
            data.episode.toString()
            ]
    request {url: uri.toString(), json: true}, (error, response, data) ->
        if error or !data or data.status === 'failure'
            deferred.reject(error)
        else
            deferred.resolve(data)

module.exports.fetch = (imdbIds) ->
    queryTorrents(imdbIds).then(formatResult)

module.exports.episodeDetail = (data) ->
    episodeDetail(data)