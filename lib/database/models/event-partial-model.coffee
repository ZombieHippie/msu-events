mongoose = require 'mongoose'

# Event Partial Schema
eventPartialSchema = mongoose.Schema {
  e: { type: mongoose.Schema.Types.ObjectId, ref: 'EventMetadata' },
  c: { type: mongoose.Schema.Types.ObjectId, ref: 'Calendar' },
  t: String, # Type: [F]raternity, [S]orority, S[P]ort, [I]nterest Group, [C]ampus Organization, [R]eligion
  s: Number  # Start
}

statics = {
}

methods = {
}

for name, staticfn of statics
  eventPartialSchema.statics[name] = staticfn
for name, methodfn of methods
  eventPartialSchema.methods[name] = methodfn

module.exports = mongoose.model 'EventPartial', eventPartialSchema