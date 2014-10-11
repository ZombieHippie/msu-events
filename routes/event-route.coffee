express = require('express')
router = express.Router()
moment = require 'moment'
async = require 'async'
{ EventMetadata, EventPartial, Calendar, TextSearch, types: allTypes } = require '../lib/database/database-mongoose'

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
  
  done?()

getSpanGet = (interval, render, limit=-1) ->
  (req, res) ->
    refresh ->
      qpage = req.query.page
      qpage = parseInt(qpage) or 0

      if interval?
        qinterval = interval
      else
        qinterval = req.query.i
        qinterval = parseInt(qinterval) or oneDayMS

      qtypes = req.query.types or allTypess

      # Query doesn't do anything yet
      qq = req.query.q or ""

      query = getPage(qpage, qinterval)
      EventPartial
      .find query
      .where("t").in qtypes.split("")
      .populate { path: 'e', select: 'e s eId i' }
      .populate { path: 'c', select: 'color name slug' }
      .sort 's'
      .exec (error, partials) ->
        res.render(render, {
          events: partials,
          page: qpage,
          types: qtypes,
          interval: qinterval,
          today,
          q: qq,
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

# Browse groups
router.get '/browse', (req, res) ->
  qpage = req.query.page
  qpage = parseInt(qpage) or 0

  qtypes = req.query.types or allTypess

  Calendar.find()
  .select 'calendarId type name slug description color'
  .limit 10
  .skip qpage
  .where("type").in qtypes.split("")
  .exec (error, calendars) ->
    if error
      res.render "error", { error }

    else
      res.render("calendar-list-browse", {
        cales: calendars,
        page: qpage,
        types: qtypes,
        allTypes,
        filterOpen: req.query.types? and req.query.types isnt allTypess 
      })

router.get '/search', (req, res) ->
  qtypes = req.query.types or allTypess

  # Query doesn't do anything yet
  qq = req.query.q or ""

  if qq.length is 0
    res.render("search-results-page", {allTypes, types:allTypess})
  else
    TextSearch.textSearch qq, {
        limit: 20
        filter: { t: { $in: qtypes.split("") } }
      }, (error, docs) ->
        if error
          res.render 'error', { error }

        else
          async.map(
            docs.results
            ((doc, cb) ->
              TextSearch
              .findById(doc.obj._id)
              .populate { path: 'e', select: 'e s eId i' }
              .populate { path: 'c', select: 'color name slug' }
              .exec cb
            )
            ((error, map) ->
              if error
                res.render "error", { error }

              else
                res.render("search-results-page", {
                  docs: map,
                  types: qtypes,
                  q: qq,
                  allTypes,
                  filterOpen: req.query.types? and req.query.types isnt allTypess 
                })
            )
        )

router.get '/week', getSpanGet(oneWeekMS, "event-list-week")

router.get '/list', getSpanGet(null, "event-list-component")

router.get '/calendar/:slug', (req, res) ->
  slug = req.params.slug
  Calendar
  .findOne({ slug })
  .select 'description color name type calendarId slug'
  .exec (error, cal) ->
    if error or not cal?
      res.render 'error', { message: "Calendar not found" }

    else
      EventPartial
      .find { c: cal, s: { $gte: today } }
      .populate { path: 'e', select: 'e s eId i' }
      .populate { path: 'c', select: 'color name slug' }
      .limit 10
      .sort 's'
      .exec (error, partials) ->
        res.render("calendar-page", {
          events: partials,
          calendar: cal,
          today,
          allTypes,
          moment # pass in the entire moment library
        })

router.get '/calendar/:slug/event/:evtname.:eid.:evts', (req, res) ->
  eId = req.params.eid
  evts = parseInt(req.params.evts)
  slug = req.params.slug
  if not evts
    res.redirect '/calendar/' + slug

  else
    EventMetadata
    .findOne({ eId })
    .select 'i hL iC s e t cal'
    .populate { path: 'cal', select: 'color name slug' }
    .exec (error, evM) ->
      if error or not evM?
        res.render 'error', { message: "Event not found" }

      else
        res.render("calendar-event-page", {
          evM,
          evts,
          today,
          allTypes,
          moment # pass in the entire moment library
        })

refresh()
module.exports = router
