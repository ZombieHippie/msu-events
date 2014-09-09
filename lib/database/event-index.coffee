async = require 'async'
{ RRule } = require 'rrule'
{ Calendar, EventMetadata } = require './database-mongoose'

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

    points = RRule.fromString(evM.r).between(evM.s, endR)

  else if evM.reId?
    tmpDel[c].push String(evM.reId) + String(evM.s)

  else
    points = [evM.s]

  e = evM.eId
  t = evM.t
  for point in points
    if point?
      s = point.getTime()
      tmpIndex[c][e + s] = {
          e, # Event ObjectId
          t, # Type
          s  # Start Date in milliseconds
        }

indexCids = (cIds, callback) ->
  tmpIndex = {}
  tmpDel = {}
  for cId in cIds
    tmpIndex[cId] = {}
    tmpDel[cId] = []

  EventMetadata.find().stream()
  .on 'data', indexEvent
  
  .on 'error', (error) ->
    tmpIndex = null
    tmpDel = null
    callback error
  
  .on 'close', ->

    # Delete recurring events
    for cId, dels in tmpDel
      for del in dels
        delete tmpIndex[cId][del]

    callback(null, tmpIndex)

    # Reset
    tmpIndex = null
    tmpDel = null

# if calendarIds is null, just process the non-suspended calendars
reindexRecurring = (calendarIds, callback) ->
  if tmpIndex? or tmpDel?
    callback new Error("Recurring events already being indexed!")

  else
    if calendarIds?
      indexCids calendarIds, callback

    else
      Calendar.getIndexedIds (error, cIds) ->
        if error?
          callback error

        else
          indexCids(cIds, callback)

exports.reindexRecurring = reindexRecurring