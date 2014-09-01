mongoose = require 'mongoose'

# Event Schema
eventSchema = mongoose.Schema {
  e: { type: mongoose.Schema.Types.ObjectId, ref: 'EventMetadata' },
  t: String, # Type: [F]raternity, [S]orority, S[P]ort, [I]nterest Group, [C]ampus Organization, [R]eligion
  s: Date    # Start
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