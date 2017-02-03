mongoose = require 'mongoose'
# textSearch = require('mongoose-text-search')

# Text Search Schema
textSearchSchema = mongoose.Schema {
  e: { type: mongoose.Schema.Types.ObjectId, ref: 'EventMetadata' }, # Optional
  c: { type: mongoose.Schema.Types.ObjectId, ref: 'Calendar' }, # Optional
  t: String # type
  s: { type: [String], text: true }, # Text to search [Name, Description]
}

statics = {
  textSearch: (query, options, callback) ->
    # Model
    TextSearch = @

    console.log { textSearch: query, options }

    searchQuery = TextSearch.find { "$text": { "$search": query } }

    if options.limit?
      searchQuery.limit options.limit
    
    if options.filter?
      searchQuery.where options.filter

    searchQuery.exec (err, res) ->
      if err?
        callback err
      else
        results = res.map (o) -> { obj: o }
        callback null, {
          results # : { obj: { _id: string } }[]
        }
}

methods = {
}

for name, staticfn of statics
  textSearchSchema.statics[name] = staticfn
for name, methodfn of methods
  textSearchSchema.methods[name] = methodfn

# textSearchSchema.plugin(textSearch)
textSearchSchema.index({ s: 'text' })

module.exports = mongoose.model 'TextSearch', textSearchSchema
