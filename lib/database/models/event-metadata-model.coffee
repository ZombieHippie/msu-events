mongoose = require 'mongoose'

# Event Schema
eventMetaSchema = mongoose.Schema {
  cId: String,  # CalendarId
  eId: String,  # EventId for syncing
  hL: String,   # htmlLink
  iC: String,   # iCalendar Link
  i: {
    name: String, # Summary of Event
    desc: String, # Description
    loc:  String  # Location as String
  },
  c: Boolean    # Cancelling event (mostly for recurring instance cancellation)  
  s: Date,      # Start
  e: Date,      # End
  r: String,    # Recurrence
  reId: String  # Recurring Parent Event ID 
}

statics = {
}

methods = {
}

for name, staticfn of statics
  eventMetaSchema.statics[name] = staticfn
for name, methodfn of methods
  eventMetaSchema.methods[name] = methodfn

module.exports = mongoose.model 'EventMetadata', eventMetaSchema