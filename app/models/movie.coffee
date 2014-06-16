mongoose = require('mongoose')
Schema = mongoose.Schema

MovieSchema = new Schema(
  _id:String
  title: String
  publicYear: Number
  date:Date
  runtime:Number
  images:
  	cover:String
  	bigImage:String
  	backdrop:String
  rating: Number
  genre: String
  imdbLink:String
  trailer: String
  overview: String
  certification:String
  seeds:Number
  torrents: 
  	'720p': 
  		seeds: Number
  		peers: Number
  		size: Number
  		url: String
  	'1080p':
  		seeds: Number
  		peers: Number
  		size: Number
  		url: String
  subtitles:
  	vi:String
  	en:String
)

MovieSchema.virtual('created_date')
  .get () ->
    return this._id.getTimestamp()
MovieSchema.virtual('imdbCode')
  .get () ->
    return this._id
  .set (imdbCode) ->
    this._id = imdbCode
MovieSchema.method 'toJSON', () ->
  movie = this.toObject()
  movie.imdbCode = this.imdbCode
  delete movie._id
  delete movie.__v
  movie
mongoose.model('Movie', MovieSchema)