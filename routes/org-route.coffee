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

module.exports = router