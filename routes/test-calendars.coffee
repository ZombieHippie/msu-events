express = require('express')
{ readFileSync } = require 'fs'

router = express.Router()
{ Calendar } = require '../lib/database.coffee'
gcal = require '../lib/google-calendar.js'

router.get '/', (req, res) ->
  Calendar.findAll (calendars) ->
    stack = JSON.stringify calendars, null, 2
    res.render("error", { title: "test-calendars", message: "List of calendars", error: { stack }})

# Refresh database of calendars
router.get '/refresh', (req, res) ->
  res.redirect '/'

router.get '/:calendarId', (req, res) ->
  # Need to get calendar by calendar ID
  req.query.calendarId = req.params.calendarId
  gcal.events.list req.query, (err, resp) ->
    if err? then console.log err
    stack = JSON.stringify resp, null, 2
    res.render("error", { title: "test-calendars", message: "List of calendar's events", error: { stack }})

module.exports = router