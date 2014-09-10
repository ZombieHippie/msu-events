express = require('express')
router = express.Router()
{ getEventsTSE } = require '../lib/database/event-index'

router.get '/', (req, res) ->
  getEventsTSE req.query.t, req.query.s, req.query.e, (error, events) ->
    if error?
      res.write error.stacktrace
      res.end()

    else
      res.render("event-list-page", { events })

router.get '/event', (req, res) ->
  res.redirect '/'

router.get '/event/:eId', (req, res) ->
  res.end("Event:#{req.params.eId}\nNot ready yet :-)")

module.exports = router
