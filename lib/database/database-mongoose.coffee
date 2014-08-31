
{ hash } = require './passhash.coffee'

mongoose = require 'mongoose'
mongoose.connect('mongodb://localhost/msu-events')
db = mongoose.connection
`
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function callback () {
  console.log("Mongoose Connected")
});
`

exports.User = require './models/user-model.coffee'
exports.Event = require './models/event-model.coffee'
