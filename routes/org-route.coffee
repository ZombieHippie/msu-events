express = require('express')
router = express.Router()
{ Organization } = require '../lib/database/database.coffee'
cal = require('../lib/database/google-calendar')

router.get '/', (req, res) ->
  res.redirect('/')

router.get '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    res.render "org-settings-page", { title: "Organization Settings" }
  else
    res.redirect '/org/' + req.params.org

# Step 1 Settings
router.post '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    oauth = cal.getOAuth()
    qsbuilder = (obj) ->
      qs = '?'
      for k, v of obj
        qs += k + '=' + v
    res.redirect 'https://accounts.google.com/o/oauth2/auth' + qsbuilder(oauth)
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


module.exports = router