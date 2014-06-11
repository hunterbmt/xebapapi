var express = require('express');
var app = express();

app.configure(function() {
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  //app.use(app.router);
  //app.use(express.static(path.join(application_root, "public")));
  app.use(express.errorHandler({
    dumpExceptions: true,
    showStack: true
  }));
});

var mongoose = require('mongoose');
var Schema = mongoose.Schema,
  ObjectId = Schema.ObjectId;

var User = new Schema({
  _id: ObjectId,
  name: String
});

var UserModel = mongoose.model('User', User);
var instance = new UserModel();
instance.name = "hunter";
mongoose.connect('mongodb://localhost/test');

app.get('/', function(req, res) {
	instance.save(function(err){
		res.send('Chào xe bắp');
	})
});

var server = app.listen(3000, function() {
  console.log('Listening on port %d', server.address().port);
});
