
fs = require 'fs'
path = require 'path'
{ hash } = require './passhash.coffee'

orgFiles = path.resolve __dirname, '../data/organizations.json'
db = JSON.parse fs.readFileSync orgFiles, 'utf8'

org = {}
# callback(Error err, Boolean isVerified, Object organization)
org.verify = (email, password, callback) ->
  callback(null, true, {email})
org.save = ->

exports.Organization = org