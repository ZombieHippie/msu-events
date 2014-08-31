
mongoose = require 'mongoose'
{ hash } = require '../passhash.coffee'

# User Schema
userSchema = mongoose.Schema {
  type:   String, # Fraternity, Sorority, Intermural Sport, Interest Group, Campus
  email:  { type: String, lowercase: true, trim: true },
  slug:   { type: String, lowercase: true, trim: true },
  name: String, # Eg. Chi Alpha
  description: String,
  calendars:  [String],
  tokens:     Object,
  verified:   Boolean
}

statics = {
  # Used to get the user associated with account
  # callback(Error, User)
  getUser: (email, callback) ->
    email = email.toLowerCase()

    userQuery = this.findOne { 'email': email }

    userQuery.select('description name slug verified type email calendars tokens')

    userQuery.exec callback

  # May not find user if user does not have a slug yet
  # callback(Error, User)
  getUserBySlug: (slug, callback) ->
    slug = slug.toLowerCase()

    userQuery = this.findOne { 'slug': slug }

    userQuery.select('description name verified type email calendars')

    userQuery.exec callback

  getAllCalendars: (callback) ->
    this.find()
    .select('calendars')
    .exec (err, users) ->
      if err?
        callback err
      else
        cals = []
        # Collect all user calendars into the same array
        (cals.push(cal) for cal in user.calendars) for user of users 
        callback null, cals
}

methods = {
  addCalendar: (name, id, callback) ->
    for cal in this.calendars when cal.id is id
      return callback(new Error("Calendar with id: #{id}, already exists"))
    this.calendars.push { name, id }
    callback(null, this)

  removeCalendarById: (id, callback) ->
    this.calendars = [cal for cal in this.calendars when cal.id isnt id]

}

for name, staticfn of statics
  userSchema.statics[name] = staticfn
for name, methodfn of methods
  userSchema.methods[name] = methodfn

module.exports = mongoose.model 'User', userSchema