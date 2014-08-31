mongoose = require 'mongoose'

{ hash } = require '../passhash.coffee'

# Event Schema
eventSchema = mongoose.Schema {
  type: String, # Fraternity, Sorority, Intermural Sport, Interest Group, Campus
  calendar: String,
  info: {
    name: String,
    description: String,
    location: String
  },
  start: Date,
  end: Date,
  recur: String
}

statics = {
  getEvents: (calendarId, callback) ->
    this.find({ calendarId })
    .exec callback
}

methods = {
}

for name, staticfn of statics
  eventSchema.statics[name] = staticfn
for name, methodfn of methods
  eventSchema.methods[name] = methodfn

module.exports = mongoose.model 'Event', eventSchema