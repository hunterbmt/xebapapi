mongoose = require('mongoose')
_ = require('lodash-node')
Q = require('q')
Movie = mongoose.model('Movie')

providers = require('../../config/providers')

module.exports.fetch = (req, res, next) ->
    filters =
        limit: 50
    filters.keywords = req.params.keywords.replace(/\s/g, '% ') if req.params.keywords
    filters.genre = req.params.genre if req.params.genre and req.params.genre is not 'All'
    filters.order = req.params.order if req.params.order
    filters.sort = req.params.sort if req.params.sort
    filters.set = req.params.set if req.params.set

    ###gen sortOpt for mongo ###
    sortOpt = {}
    sortOpt[req.params.sort] = 1
    sortOpt[req.params.sort] = - 1 if req.params.order is 'desc'

    Movie.find({
        title: new RegExp(filters.keywords)
    } )
    .where('genre').equals(filters.genre)
    .sort(sortOpt)
    .skip(filters.limit * (filters.set - 1) )
    .limit(filters.limit)
    .exec (err, movies) ->
        
        throw new Error(err) if err
        if _.isEmpty(movies)
            fetchYtsData(filters, res)
        else
            res.send(movies)

    return next()

fetchYtsData = (filters, res) ->
    ytsPromise = providers.movie.fetch(filters)
    idsPromise = ytsPromise.then(providers.movie.extractImdbs)
    subtitlePromise = idsPromise.then(providers.movieSub.fetch)
    metadataPromise = idsPromise.then(providers.movieMetadata.fetch)
    Q.all([ytsPromise, subtitlePromise, metadataPromise])
     .spread (movies, subtitles, metadatas) ->
            _.each movies, (movie) ->
                id = movie.imdbCode

                info = metadatas[id]
                movie.subtitles = subtitles[id]
                if info
                    movie.images.cover = info.cover
                    movie.images.bigImage = info.bigImage
                    movie.images.backdrop = info.backdrop
                    _.extend movie, _.pick info, ['overview','certification','trailer','runtime']
            res.send(movies)
            cacheMoviesToMongo(movies)
cacheMoviesToMongo = (movies) ->
    _.each movies, (movie) ->
        movie = new Movie(movie)
        movie.save (err) ->
            throw new Error(err) if err

