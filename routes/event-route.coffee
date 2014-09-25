express = require('express')
router = express.Router()
moment = require 'moment'
{ EventPartial, types: allTypes } = require '../lib/database/database-mongoose'

allTypess = Object.keys(allTypes).join("")

today = null
oneDayMS = 24 * 60 * 60 * 1000
oneWeekMS =  7 * oneDayMS

getPage = (index, interval) ->
  adv = interval * index
  { s: { $gte: today + adv, $lt: today + adv + interval} }

refresh = (done) ->
  a = new Date()
  newToday = new Date(a.getYear() + 1900, a.getMonth(), a.getDate()).getTime()
  if today isnt newToday
    today = newToday
  
  done()

getSpanGet = (interval, render) ->
  (req, res) ->
    refresh ->
      qpage = req.query.page
      qpage = parseInt(qpage) or 0

      qtypes = req.query.types or allTypess

      query = getPage(qpage, interval)
      EventPartial
      .find query
      .where("t").in qtypes.split("")
      .populate { path: 'e', select: 'iC hL e s eId cId i' }
      .populate { path: 'c', select: 'color name slug' }
      .sort 's'
      .exec (error, partials) ->
        res.render(render, {
          events: partials,
          page: qpage,
          types: qtypes,
          interval,
          today,
          allTypes,
          moment, # pass in the entire moment library
          filterOpen: req.query.types? and req.query.types isnt allTypess 
        })

dayView = getSpanGet(oneDayMS, "event-list-day")
router.get '/', ((req,res) -> res.redirect('/today'))
router.get '/day', dayView
router.get '/today', (req, res) ->
  if req.query.page? and parseInt(req.query.page) isnt 0
    res.redirect req.originalUrl.replace(/^\/today/, "/day")
  else
    dayView req, res

router.get '/week', getSpanGet(oneWeekMS, "event-list-week")

router.get '/event', (req, res) ->
  res.redirect '/'

router.get '/event/:eId', (req, res) ->
  res.end("Event:#{req.params.eId}\nNot ready yet :-)")

module.exports = router
