express = require('express')
router = express.Router()
{ Organization } = require '../lib/database.coffee'

router.get '/', (req, res) ->
  if req.query.logout?
    loggedOut = true
    req.session.destroy ->
      delete res.locals.org
      res.render("auth-page", { action: "Login", title: "Organization Login", loggedOut: true })
  else
    res.render("auth-page", { action: "Login", title: "Organization Login" })

router.post '/', (req, res) ->
  Organization.verify req.body.email, req.body.password, (error, isVerified, organization) ->
    if error?
      throw error
    else if isVerified
      req.session.org = organization
      res.redirect '/'
    else
      res.render "auth-page", { action: "Login", title: "Organization Login", failed: true }
module.exports = router