_ = require('lodash-node')
request = require('request')
Q = require('q')

baseUrl = 'http://api.yifysubtitles.com/subs/'
mirrorUrl = 'http://api.ysubs.com/subs/'
prefix = 'http://www.yifysubtitles.com'


querySubtitles = (imdbIds) ->
  return {} if _.isEmpty imdbIds
  url = baseUrl + imdbIds.join('-')
  mirrorurl = mirrorUrl + imdbIds.join('-')

  deferred = Q.defer()

  request {url: url, json: true} , (error, response, data) ->
    if error or response.statusCode is not 200 or !data or !data.success
      request {url: mirrorurl, json: true} , (error, response, data) ->
          if error or response.statusCode is not 200 or !data or !data.success
              deferred.reject(error)
          else
              deferred.resolve(data)
    else
      deferred.resolve(data)

  deferred.promise

formatResult = (result) ->
  allSubs = {} ;
  _.each result.subs, (langs, imdbId) ->
        movieSubs = {}
        _.each langs, (subs, lang) ->
              langCode = languageMapping[lang];
              if langCode
                movieSubs[langCode] = prefix + _.max(subs, (s) -> return s.rating).url

        allSubs[imdbId] = movieSubs
  allSubs

languageMapping =
  'english': 'en',
  'vietnamese': 'vi'

module.exports.fetch = (imdbIds) ->
  querySubtitles(imdbIds).then(formatResult)