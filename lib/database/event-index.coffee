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
    tmpDel[c].push String(evM.reId) + String(evM.s.getTime())

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
    console.log tmpDel, tmpIndex


    # Delete recurring events
    for cId, dels in tmpDel
      for del in dels
        delete tmpIndex[cId][del]

    # Timeout is good, I guess
    setTimeout(
      ->
        # Reset
        tmpIndex = null
        tmpDel = null
      , 100
    )

    callback(null, tmpIndex)


# if calendarIds is null, just process the non-suspended calendars
reindexRecurring = (calendarIds, callback) ->
  if tmpIndex? or tmpDel?
    callback new Error("Recurring events already being indexed!")

  else
    if calendarIds?
      indexCids calendarIds, callback

    else
      callback new Error "need calendarIds"

exports.reindexRecurring = reindexRecurring