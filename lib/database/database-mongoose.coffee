
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
exports.EventMetadata = require './models/event-metadata-model.coffee'
exports.Calendar = require './models/calendar-model.coffee'
