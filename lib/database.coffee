
fs = require 'fs'
path = require 'path'
{ hash } = require './passhash.coffee'

orgFiles = path.resolve __dirname, '../data/organizations.json'
db = JSON.parse fs.readFileSync orgFiles, 'utf8'

org = {}
# callback(Error err, Boolean isVerified, Object organization)
org.verify = (email, password, callback) ->
  email = email.toLowerCase()
  if not db[email]? or db[email].password isnt password
    # Email does not exist in database, or wrong password
    callback(null, false)
  else
    callback(null, true, db[email])

# callback(Error err, Object organization)
org.verifyEmail = (email, emailToken, callback) ->
  error = new Error("Oops email verification not set-up yet!")
  error.status = 501
  callback(error)

org.register = (email, obj, callback) ->
  email = email.toLowerCase()
  if db[email]?
    err = new Error("Email already in use!")
    err.status = 401
    callback err
  else
    db[email] = obj
    org.save (error) ->
      callback error, obj

org.save = (callback) ->
  str = JSON.stringify db, null, 2
  fs.writeFileSync orgFiles, str, "utf8"
  callback()

exports.Organization = org