express = require('express')
router = express.Router()
{ Organization } = require '../lib/database/database.coffee'

router.get '/', (req, res) ->
  res.redirect('/')

router.get '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    res.render "org-settings-page", { title: "Organization Settings" }
  else
    res.redirect '/org/' + req.params.org

router.post '/:org/settings', (req, res) ->
  if req.session.org?.slug is req.params.org
    org = req.session.org
    org.calendars.push {
      id: req.body['calendar-id']
      name: req.body['calendar-name']
    }
    # Add calendar
    Organization.saveObject org.email, org, (error) ->
      if error
        throw error
      res.render "org-settings-page", { title: "Organization Settings" }
  else
    res.redirect '/org/' + req.params.org


module.exports = router