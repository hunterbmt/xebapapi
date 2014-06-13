mongoose = require('mongoose')
Schema = mongoose.Schema

UserSchema = new Schema({
  name: String
})

UserSchema.virtual('date')
  .get () ->
    return this._id.getTimestamp()

mongoose.model('User', UserSchema);