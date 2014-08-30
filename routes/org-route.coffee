express = require('express')
router = express.Router()
{ Organization } = require '../lib/database/database.coffee'
gcal = require('../lib/database/google-calendar')

router.get '/', (req, res) ->
  res.redirect('/')

# Step 1 Settings
router.post '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    ###
    org = req.session.org
    org.calendars.push {
      id: req.body['calendar-id']
      name: req.body['calendar-name']
    }
    # Add calendar
    Organization.saveObject org.email, org, (error) ->
      if error
        throw error
    ###
    res.render "org-settings-page", { title: "Organization Settings" }
  else
    res.redirect '/org/' + req.params.org

# Step 2 Auth
router.get '/~google-oauth', gcal.handleOAuth2
module.exports = router

# Normal organization settings page
router.get '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    if req.query.auth?
      oauth = gcal.getOAuthParameters(req.params.org)
      queryStringBuilder = (obj) ->
        qs = '?'
        for k, v of obj
          qs += k + '=' + v + '&'
        return qs
      res.redirect 'https://accounts.google.com/o/oauth2/auth' + queryStringBuilder(oauth)
    else
      res.render "org-settings-page", { title: "Organization Settings" }
  else
    res.redirect '/org/' + req.params.org

router.get '/:org', (req, res) ->
  res.redirect '/'