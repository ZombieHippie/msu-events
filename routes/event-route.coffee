express = require('express')
router = express.Router()
moment = require 'moment'
{ EventPartial, types: allTypes } = require '../lib/database/database-mongoose'

allTypess = Object.keys(allTypes).join("")

weekStart = null
weekEnd = null
oneWeek =  7 * 24 * 60 * 60 * 1000

getPage = (index) ->
  adv = oneWeek * index
  { s: { $gte: weekStart + adv, $lt: weekEnd + adv } }

refresh = (done) ->
  a = new Date()
  today = new Date(a.getYear() + 1900, a.getMonth(), a.getDate()).getTime()
  if weekStart isnt today
    weekStart = today
    weekEnd = weekStart + oneWeek
  
  done()


router.get '/', (req, res) ->
  refresh ->
    page = req.query.page
    page = parseInt(page) or 0

    types = req.query.types or allTypess

    query = getPage(page)
    EventPartial
    .find query
    .where("t").in types.split("")
    .populate { path: 'e', select: 'iC hL e s eId cId i' }
    .populate { path: 'c', select: 'color name slug' }
    .sort 's'
    .exec (error, partials) ->
      res.render("event-list-page", {
        events: partials,
        page,
        oneWeek,
        weekStart,
        moment, # pass in the entire moment library
        allTypes,
        types,
        eventsTitle: "Events by Week",
        filterOpen: req.query.types? and req.query.types isnt allTypess 
      })

router.get '/event', (req, res) ->
  res.redirect '/'

router.get '/event/:eId', (req, res) ->
  res.end("Event:#{req.params.eId}\nNot ready yet :-)")

module.exports = router
