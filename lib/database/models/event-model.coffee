mongoose = require 'mongoose'

{ hash } = require '../passhash.coffee'

# Event Schema
eventSchema = mongoose.Schema {
  type: String, # Fraternity, Sorority, Intermural Sport, Interest Group, Campus
  info: {
    name: String,
    description: String,
    location: String
  }
}

statics = {
}

methods = {
}

for name, staticfn of statics
  eventSchema.statics[name] = staticfn
for name, methodfn of methods
  eventSchema.methods[name] = methodfn

module.exports = mongoose.model 'Event', eventSchema