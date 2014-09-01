
async = require 'async'
googleHook = require './google-calendar'
{ Calendar, EventMetadata, Event } = require './database-mongoose'

ISO = (str) ->
  new Date(Date.parse(str))

updateEventAndReccurring = (evM, gevent, callback) ->
  # Make changes
  evM.hL = gevent.htmlLink      if gevent.htmlLink?
  evM.iC = gevent.iCalUID       if gevent.iCalUID?
  
  evM.i.name = gevent.summary       if gevent.summary?
  evM.i.loc  = gevent.location      if gevent.location?
  evM.i.desc = gevent.description   if gevent.description?
  
  evM.s = ISO(gevent.start.dateTime)  if gevent.start?.dateTime?
  evM.e = ISO(gevent.end.dateTime)    if gevent.end?.dateTime?

  evM.r = gevent.recurrence[0]        if gevent.recurrence?.length
  evM.reId = gevent.recurringEventId  if gevent.recurringEventId?

  # TODO Event Pointers

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

      total = {
        updated: 0,
        created: 0,
        cancelled: 0,
        removed: 0
      }

      processEvents = (nextPage) ->
        listOptions = {
          calendarId,
          syncToken: nextSyncToken,
          fields,
          auth
        }

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

                      updateEventAndReccurring evM, gevent, nextGevent

                    else
                      # gevent is cancelled
                      if evM?
                        total.removed++
                        evM.remove nextGevent

                      else
                        # gevent is cancelled and not created yet
                        # Possibly an instance of recurring event instance cancellation
                        
                        total.cancelled++

                        # Create New eventMetadata
                        evM = new EventMetadata {
                          cId:  calendarId,  # CalendarId
                          eId,  # EventId for syncing
                          c: true, # Cancelling event 
                          reId: gevent.recurringEventId,
                          s:   gevent.originalStartTime.dateTime,
                        }

                        evM.save nextGevent()

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
        processEvents
        , (-> !!nextPageToken)
        , (error) ->
          if error
            callback error
          else
            callback null, total
      )      


