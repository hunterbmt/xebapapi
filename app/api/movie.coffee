mongoose = require('mongoose')
_ = require('lodash-node')
Movie = mongoose.model('Movie')

module.exports.fetch = (req,res,next) ->
	filters = 
		sort:'seeds',
		limit:50
  filters.keywords = req.params.keywords.replace(/\s/g, '% ') if req.params.keywords
  filters.genre = req.params.genre if req.params.genre
  filters.order = req.params.order if req.params.order
  filters.sort = req.params.sorter if req.params.sorter
  filters.set = req.params.page if req.params.page

  /* gen sortOpt for mongo */
  sortOpt = {}
  sortOpt[req.params.sorter] = 1
  sortOpt[req.params.sorter] = -1 if req.params.order === 'desc'

	Movie.find({
		title:new RegExp(filters.keywords)
	})
	.where('genre').equals(filters.genre)
	.sort(sortOpt)
	.skip(filters.limit * (filters.set - 1))
	.limit(filters.limit)
	.select('-_id')
	.exec (err,movies) ->
		throw new Error(err) if err
		if _.isEmpty(movies)
			fetchYtsData(filters,res)
		else
			res.send(movies)

    return next()

fetchYtsData = (filters,res) ->
	Q = require('q')
	yts = require('../app/providers/yts')
	ysubs = require('../app/providers/ysubs')
	trakttv = require('../app/providers/trakttv')
	ytsPromise = yts.fetch(filters)
	idsPromise = ytsPromise.then(yts.extractImdbs)
	subtitlePromise = idsPromise.then(ysubs.fetch)
	metadataPromise = idsPromise.then(trakttv.fetch)
	Q.all([ytsPromise,subtitlePromise,metadataPromise])
	 .spread (movies,subtitles,metadatas) ->
	 		_.each movies, (movie) ->
	 			id = movie.imdbCode
	 			info = metadatas[id]
	 			movie.subtitles =  subtitles[id]
	 			movie.images.bigImage = info.bigImage
	 			movie.images.backdrop = info.backdrop
	 			_.extend movie, _.pick info, ['overview','certification','trailer']
	 		res.send(movies)
	 		//insert to db
