# Here we are indexing any calendarIds of events and sifting through repeating events

async = require 'async'
{ RRule } = require 'rrule'
{ Calendar, EventMetadata, EventPartial } = require './database-mongoose'

###
# Super temporary lookup
partials = []
partialsBetween = (t1, t2) ->
  (a) ->
    a.s > t1 and a.s < t2
partialsByTypes = (types) ->
  (a) ->
    -1 != types.indexOf(a.t)
###
indexing = false
tmpIndex = null
tmpDel = null
indexEvent = (evM) ->
  c = evM.cId

  if not tmpIndex[c]?
    return

  if evM.r
    # Duplicate start time and add 2 years to limit the amount of recursions
    endR = new Date(evM.s)
    endR.setYear(endR.getYear() + 1902)

    # create rule and set first date
    rruleStr = (
      evM.r.replace(/DTSTART=[\w\d]+/,"") +
      ";" +
      RRule.optionsToString({ dtstart: evM.s }) # Need a dtstart so the time is exact
    ).replace(/;+/g, ";")
    rule = RRule.fromString rruleStr
    
    points = rule.between(evM.s, endR)

  else if evM.reId?
    tmpDel[c].push String(evM.reId) + String(evM.s.getTime())

    if not evM.c
      # Not cancelled event
      console.log "Recurring event modified instance", evM

  else
    points = [evM.s]

  if points?
    # Add points to index
    e = evM.eId
    t = evM.t
    for point in points
      if point?
        s = point.getTime()
        tmpIndex[c][String(e) + String(s)] = {
            e: evM, # Event Metadata Document
            c: evM.cal, # Calendar Document
            t, # Type
            s  # Start Date in milliseconds
          }

indexCids = (cIds, callback) ->
  tmpIndex = {}
  tmpDel = {}
  for cId in cIds
    tmpIndex[cId] = {}
    tmpDel[cId] = []

  EventMetadata.find({ cId: { $in: cIds } }).stream()
  .on 'data', indexEvent
  
  .on 'error', (error) ->
    tmpIndex = null
    tmpDel = null
    callback error
  
  .on 'close', ->
    # Delete recurring events
    for cId, dels of tmpDel
      for del in dels
        delete tmpIndex[cId][del]

    callback(null, tmpIndex )
    tmpIndex = null
    tmpDel = null

deletePartialsWithCalendar = (calendarDoc, nextCal) ->
  EventPartial.remove({c:calendarDoc}, nextCal)

deletePartialsWithCId = (calendarId, nextCId) ->
  Calendar.find({ calendarId }).exec (error, cals) ->
    if error?
      nextCId error

    else
      async.each cals, deletePartialsWithCalendar, nextCId

savePartial = (partialObj, nextPartial) ->
  (new EventPartial(partialObj)).save nextPartial

reindexRecurring = (calendarIds, callback) ->
  if tmpIndex? or tmpDel?
    callback new Error("Recurring events already being indexed!")

  else
    if calendarIds?
      indexCids calendarIds, (error, index) ->
        if error?
          callback error

        else
          allpartials = []
          for cId, calObj of index
            for eId, evMPartial of calObj
              allpartials.push evMPartial


          # This sorting may be uneccessary, but maybe not.
          allpartials = allpartials.sort (a, b) ->
            a.s - b.s

          async.each calendarIds, deletePartialsWithCId, (error) -> 
            if error?
              callback error

            else
              async.each allpartials, savePartial, callback

    else
      callback new Error "need calendarIds"

exports.reindexRecurring = reindexRecurring

###
getTSE = (t, s, e) ->
  if s and s.getTime?
    s = s.getTime()
  if e and e.getTime?
    e = e.getTime()
  res = partials.slice(0)
  res = res.filter(partialsBetween(s, e)) if s and e
  res = res.filter(partialsByTypes(t)) if t
  return res

_s = (o, t) ->
  o.s = t if typeof o is "object"
  return o

exports.getEventsTSE = (t, s, e, callback) ->
  evPs = getTSE t, s, e
  console.log "evPs", evPs
  evMsTmp = {}
  async.map(
    evPs
    , (evP, nextEvP) ->
      if evMsTmp[evP.e]?
        nextEvP(null, _s(evMsTmp[evP.e], evP.s))

      else
        EventMetadata.findOne({ eId: evP.e })
        .exec (error, doc) ->
          if error?
            nextEvP error

          else
            newEvP = _s(doc?.toJSON?(), evP.s)
            evMsTmp[evP.e] = newEvP

            nextEvP null, newEvP

    , callback
  )
###