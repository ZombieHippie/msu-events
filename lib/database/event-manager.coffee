
async = require 'async'
googleHook = require './google-calendar'
{ RRule } = require 'rrule'
{ Calendar, EventMetadata, EventPartial } = require './database-mongoose'
{ reindexRecurring } = require './event-index'


# Super temporary lookup
partials = []
partialsBetween = (t1, t2) ->
  (a) ->
    a.s > t1 and a.s < t2
partialsByTypes = (types) ->
  (a) ->
    -1 != types.indexOf(a.t)

ISO = (str) ->
  new Date(Date.parse(str))

updateEvent = (evM, gevent, t, callback) ->
  # Make changes if changed
  evM.s = ISO(gevent.start.dateTime)  if gevent.start?.dateTime?
  evM.e = ISO(gevent.end.dateTime)    if gevent.end?.dateTime?

  evM.hL = gevent.htmlLink      if gevent.htmlLink?
  evM.iC = gevent.iCalUID       if gevent.iCalUID?
  
  evM.i.name = gevent.summary       if gevent.summary?
  evM.i.loc  = gevent.location      if gevent.location?
  evM.i.desc = gevent.description   if gevent.description?

  evM.t = t

  evM.r = gevent.recurrence[0].replace(/^RRULE:/, "")        if gevent.recurrence?.length
  evM.reId = gevent.recurringEventId  if gevent.recurringEventId?

  evM.save callback



exports.indexEvents = (auth, calendarId, callback) ->
  Calendar.getCalendar calendarId, (error, calendar) ->
    if error?
      callback error
    
    else if not calendar?
      # Calendar not set-up
      callback null

    else
      gcalendar = googleHook.getCalendar()

      fields = "items(description,end,htmlLink,iCalUID,id,recurrence,location,recurringEventId,start,status,summary,visibility),nextPageToken,nextSyncToken,updated"
      
      # This nextPageToken is set if there is another page
      nextPageToken = null

      nextSyncToken = calendar.nextSyncToken

      calendarType = calendar.type

      total = {
        updated: 0,
        created: 0,
        cancelled: 0,
        removed: 0
      }

      processEvents = (nextPage) ->
        listOptions = {
          calendarId,
          fields,
          auth
        }

        if nextSyncToken?
          listOptions.syncToken = nextSyncToken

        if nextPageToken?
          listOptions.nextPageToken = nextPageToken
          nextPageToken = null

        gcalendar.events.list listOptions, (error, geventList) ->
          if error?
            nextPage error
          else
            
            async.each(
              geventList.items
              , (gevent, nextGevent) ->
                ### gevent
                {
                 "id": "5mg6i716i2o8s43k2pvgel2n2c_20140905T000000Z",
                 "status": "confirmed",
                 "htmlLink": "https://www.google.com/calendar/event?eid=NW1nNmk3MTZpMm84czQzazJwdmdlbDJuMmNfMjAxNDA5MDVUMDAwMDAwWiBtc2d6aHRAbQ",
                 "summary": "C Group - Chi Alpha",
                 "start": {
                  "dateTime": "2014-09-04T19:00:00-05:00"
                 },
                 "end": {
                  "dateTime": "2014-09-04T21:00:00-05:00"
                 },
                 "recurringEventId": "5mg6i716i2o8s43k2pvgel2n2c",
                 "iCalUID": "5mg6i716i2o8s43k2pvgel2n2c@google.com"
                },
                ###

                # Find in database
                eId = gevent.id

                EventMetadata.findOne { eId }
                .exec (error, evM) ->
                  if error?
                    console.log "nextGevent"
                    nextGevent error
                  else
                    if gevent.status isnt "cancelled"
                      if not evM?
                        # Create New eventMetadata
                        evM = new EventMetadata {
                          cId:  calendarId,  # CalendarId
                          eId,  # EventId for syncing
                          i: { name: null, desc: null, loc: null }
                        }
                        total.created++

                      else
                        total.updated++

                      updateEvent evM, gevent, calendarType, nextGevent

                    else
                      # gevent is cancelled
                      if evM?
                        total.removed++
                        evM.remove nextGevent

                      else
                        # gevent is cancelled and not created yet
                        # Possibly an instance of recurring event instance cancellation
                        
                        total.cancelled++

                        ###

                        # TODO handle cancelling

                        # Create New eventMetadata
                        evM = new EventMetadata {
                          cId:  calendarId,  # CalendarId
                          eId,  # EventId for syncing
                          c: true, # Cancelling event 
                          reId: gevent.recurringEventId,
                          s:   gevent.originalStartTime.dateTime,
                        }

                        evM.save nextGevent
                        ###
                        
                        nextGevent()

              , (error) ->
                if error?
                  nextPage error
                else
                  if geventList.nextPageToken?
                    nextPageToken = geventList.nextPageToken

                  # the nextSyncToken is only returned on the last page of results
                  else if geventList.nextSyncToken?
                    calendar.nextSyncToken = geventList.nextSyncToken
                    calendar.save nextPage

                  else
                    nextPage(new Error "Expected nextPageToken or nextSyncToken")
            ) # async end

      async.doWhilst(
        processEvents           # do
        , (-> !!nextPageToken)  # while
        , (error) ->            # then
          if error
            callback error
          else
            reindexRecurring [calendarId], (error, index) ->
              callback error, total
      )

