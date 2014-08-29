express = require('express')
router = express.Router()
{ Organization } = require '../lib/database/database.coffee'

router.get '/', (req, res) ->
  res.render("auth-page", { action: "Register", title: "Organization Register" })

router.post '/', (req, res) ->
  obj = {
    name: req.body.name
    slug: req.body.name.toLowerCase().replace(/[^a-zA-Z0-9]+/g, "-")
    email: req.body.email
    password: req.body.password
    calendars: []
  }
  Organization.register req.body.email, obj, (error, organization) ->
    if error?
      throw error
    else
      req.session.org = organization
      res.redirect '/'

module.exports = router