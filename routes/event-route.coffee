express = require('express')
router = express.Router()
{ EventPartial } = require '../lib/database/database-mongoose'

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

    query = getPage(page)
    EventPartial
    .find query
    .populate { path: 'e', select: 'iC hL e s eId cId i' }
    .exec (error, partials) ->
      console.log query, partials
      res.render("event-list-page", { events: partials, page })

router.get '/event', (req, res) ->
  res.redirect '/'

router.get '/event/:eId', (req, res) ->
  res.end("Event:#{req.params.eId}\nNot ready yet :-)")

module.exports = router
