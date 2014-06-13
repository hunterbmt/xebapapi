mongoose = require('mongoose')
_ = require('lodash-node')
User = mongoose.model('User')

exports.getAll = (req,res,next) ->
  User.find (err,users) ->
    throw new Error(err) if err
    users = _.map users, (user) ->
      return_user = user.toObject()
      delete return_user._id
      return_user.create_date = user.date
      return_user

    res.send(users)
    return next()
  