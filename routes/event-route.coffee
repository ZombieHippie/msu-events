express = require('express')
router = express.Router()
{ getEventsTSE } = require '../lib/database/event-index'

weekEvents = null
weekStart = null
weekEnd = null
dirty = false

refresh = (done) ->
  a = new Date()
  today = new Date(a.getYear() + 1900, a.getMonth(), a.getDate()).getTime()
  if weekStart isnt today or dirty is true
    weekStart = today
    weekEnd = weekStart + (7 * 24 * 60 * 60 * 1000)
    getEventsTSE null, weekStart, weekEnd, (error, events) ->
      if error?
        console.error "refresh weekStart/weekEnd error:", error

      else
        weekEvents = events

      dirty = false
      done()
  else
    done()

router.get '/refresh', (req, res) ->
  if req.session.email?
    dirty = true
  res.redirect '/'

router.get '/', (req, res) ->
  refresh ->
    res.render("event-list-page", { events: weekEvents })

router.get '/event', (req, res) ->
  res.redirect '/'

router.get '/event/:eId', (req, res) ->
  res.end("Event:#{req.params.eId}\nNot ready yet :-)")

module.exports = router
