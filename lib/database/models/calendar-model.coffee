
mongoose = require 'mongoose'

# Event Schema
calendarSchema = mongoose.Schema {
  owner:      String, # Email
  calendarId: String,
  type:   String, # [F]raternity, [S]orority, S[P]ort, [I]nterest Group, [C]ampus Organization, [R]eligion
  name:   String,
  slug:   { type: String, lowercase: true, trim: true },
  description: String,
  color:    String,
  nextSyncToken: String,
  suspended: Boolean # Not displayed but still indexed TODO
}

statics = {
  getCalendar: (calendarId, callback) ->
    this.findOne({ calendarId })
    .exec callback
}

methods = {
}

for name, staticfn of statics
  calendarSchema.statics[name] = staticfn
for name, methodfn of methods
  calendarSchema.methods[name] = methodfn

module.exports = mongoose.model 'Calendar', calendarSchema