
fs = require 'fs'
path = require 'path'
{ hash } = require './passhash.coffee'

orgFiles = path.resolve __dirname, '../../data/organizations.json'
orgDB = JSON.parse fs.readFileSync orgFiles, 'utf8'

Calendar = {}
Calendar.findAll = (callback) ->
  res = []
  for email, organization of orgDB
    for calendar in organization.calendars
      res.push {
        id: calendar.id
        name: calendar.name
        type: organization.type
        org: organization.name
      }
  res.sort (a, b) ->
    a.name < b.name
  callback res

exports.Calendar = Calendar

Organization = {}
# callback(Error err, Boolean isVerified, Object organization)
Organization.verify = (email, password, callback) ->
  email = email.toLowerCase()
  if not orgDB[email]? or orgDB[email].password isnt password
    # Email does not exist in database, or wrong password
    callback(null, false)
  else
    callback(null, true, orgDB[email])

# callback(Error err, Object organization)
Organization.verifyEmail = (email, emailToken, callback) ->
  error = new Error("Oops email verification not set-up yet!")
  error.status = 501
  callback(error)

Organization.register = (email, obj, callback) ->
  email = email.toLowerCase()
  if orgDB[email]?
    err = new Error("Email already in use!")
    err.status = 401
    callback err
  else
    orgDB[email] = obj
    Organization.save (error) ->
      callback error, obj

Organization.saveObject = (email, object, callback) ->
  orgDB[email] = object
  Organization.save(callback)

Organization.save = (callback) ->
  str = JSON.stringify orgDB, null, 2
  fs.writeFileSync orgFiles, str, "utf8"
  callback()

Organization.findAll = (callback) ->
  res = []
  for email, organization of orgDB
    res.push organization
  res.sort (a, b) ->
    a.name < b.name
  callback res

exports.Organization = Organization