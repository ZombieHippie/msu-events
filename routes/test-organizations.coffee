express = require('express')
router = express.Router()
{ Organization } = require '../lib/database.coffee'

router.get '/', (req, res) ->
  Organization.findAll (orgs) ->
    stack = JSON.stringify orgs, null, 2
    res.render("error", { title: "test-organizations", message: "List of organizations", error: { stack } })

module.exports = router