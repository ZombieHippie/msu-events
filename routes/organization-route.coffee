express = require('express')
router = express.Router()
async = require 'async'
eventManager = require '../lib/database/event-manager'
{ User, Calendar, EventMetadata, EventPartial } = require '../lib/database/database-mongoose'
googleHook = require('../lib/database/google-calendar')

# Organization types
types = {
  "C": "Campus Organization",
  "I": "Interest Group",
  "F": "Fraternity",
  "S": "Sorority",
  "R": "Religion",
  "A": "Academic",
  "P": "Sport",
  "O": "Other"
}

router.get '/', (req, res) ->
  res.redirect('/')
###
# Debug purp
router.get '/reindex-2', (req, res) ->
  Calendar.getIndexedCalendars (error, cIds) ->
    if error?
      res.end("Error: #{error.message}\n\n#{error.stack}")
    
    else
      eventManager.reindexEvents cIds, (error, index) ->
        if error?
          res.end("Error: #{error.message}\n\n#{error.stack}")
        else
          res.set 'Content-Type', 'application/json'

          res.write JSON.stringify(index, null, 2)

          res.end()

router.get '/reindex', (req, res) ->
  email = req.session.email
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.message
      else
        # # Get auth for querying events
        # auth = googleHook.getAuth user.tokens.access_token

        eventManager.reindexEvents user.calendars, (error, index) ->
          if error?
            res.end("Error: #{error.message}\n\n#{error.stack}")
          else
            res.set 'Content-Type', 'application/json'

            res.write JSON.stringify(index, null, 2)

            res.end()

  else
    res.redirect '/'
###
###
router.get '/refresh', (req, res) ->
  email = req.session.email
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.message
      else
        # Get auth for querying events
        auth = googleHook.getAuth user.tokens.access_token
        
        async.each(
          user.calendars
          , (calendarId, nextCalendar) ->
            eventManager.indexEvents auth, calendarId, (error, total) ->
              if error?
                console.error error
                nextCalendar error

              else
                res.write """
                Updated calendar: #{calendarId}
                  #{total.updated} events modified
                  #{total.removed} events removed
                  #{total.cancelled} events cancelled
                  #{total.created} events created\n
                """
                nextCalendar()

          , (error) ->
            if error?
              res.end("Error: #{error.message}\n\n#{error.stack}")
            else
              res.end("Updated Events")
        )
  else
    res.redirect '/'
###
# Normal organization settings page
router.get '/settings', (req, res) ->
  email = req.session.email
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.message
      else
        # Get auth for querying calendars
        auth = googleHook.getAuth user.tokens.access_token
        
        # Get calendar list
        listOptions = {
          auth,
          minAccessRole: "reader",
          fields: "items(accessRole,backgroundColor,description,foregroundColor,id,location,summary,timeZone)"
        }
        googleHook.getCalendar().calendarList.list listOptions, (error, calendarList) ->
          if error?
            res.redirect '/?error=' + error.message
          else
            Calendar.find({ owner: user.email })
            .exec (error, mcalendars)->
              if error?
                res.redirect '/?error=' + error.message
              else
                calendarIds = {}
                for c in mcalendars
                  calendarIds[c.calendarId] = c
                for item in calendarList.items
                  c = calendarIds[item.id]
                  item.checked = c?
                  if c?
                    item.suspended = c.suspended
                    item.mdescription = c.description
                    item.mname = c.name
                    item.mtype = c.type
                    item.mindexinfo = c.indexInfo
                    if c.lastIndex?.toLocaleString?
                      item.mlastindex = c.lastIndex.toLocaleString().replace(/(:\d\d)[^:]+$/, "$1")
                    else
                      item.mlastindex = "Unknown"

                acted = null

                render = (error) ->
                  if error?
                    console.error "RENDERERROR", error
                    res.redirect "/?error=" + error
                  else
                    if acted
                      res.redirect "/organization/settings"
                    else
                      calendars = calendarList.items.sort (a, b) ->
                        if a.checked isnt b.checked
                          return if a.checked then -1 else 1
                        else if a.suspended isnt b.suspended
                          return if a.suspended then 1 else -1
                        else
                          return if a.summary.localeCompare(b.summary)
                      locals = {
                        title: "Organization Settings",
                        types,
                        calendars
                      }

                      res.render "organization-settings-page", locals

                a = req.query.a
                cId = req.query.cId
                if a and calendarIds[cId]?
                  acted = { a, targetCalendar: calendarIds[cId].name }

                  switch a

                    when "unsuspend"
                      Calendar.getCalendar cId, (error, cal) ->
                        if error? then render error else
                        if cal?
                          cal.suspended = false
                          cal.save render
                        else
                          render "Calendar-doesnt-exist!"

                    when "suspend"
                      Calendar.getCalendar cId, (error, cal) ->
                        if error?
                          render error
                        else if cal?
                          cal.suspended = true
                          cal.save (error) ->
                            if error?
                              render error
                            else
                              EventPartial.remove {c:cal}, render
                        else
                          render "Calendar-doesnt-exist!"

                    when "delete"
                      user.calendars = user.calendars.filter ((e)->e.calendarId isnt cId)
                      user.save (error)->
                        if error? then render error else

                          Calendar.getCalendar cId, (error, cal) ->
                            if error? then render error else

                            if cal?
                              EventPartial.remove {c:cal}, (error) ->
                                if error?
                                  render error

                                else
                                  EventMetadata.remove {cId}, (error) ->
                                    if error?
                                      render error
                                    else
                                      Calendar.remove {calendarId: cId}, render
                            else
                              render "Calendar-doesnt-exist!"

                    when "reindex"
                      eventManager.indexEvents auth, cId, render

                    else
                      render()

                else if a is "activate"
                  # Add calendar to user's calendars
                  user.calendars.push cId
                  user.save (error, user) ->
                    if error?
                      render error
                    else
                      getOptions = {
                        auth,
                        calendarId: cId,
                        fields: "backgroundColor,description,summary"
                      }

                      googleHook.getCalendar().calendarList.get getOptions, (error, gcalendar) ->
                        if error? then render error
                        else
                          activatingCal = new Calendar {
                            calendarId: cId,
                            owner: email,
                            name: gcalendar.summary,
                            slug: gcalendar.summary.toLowerCase().replace(/[^a-z0-9]+/g, "-"),
                            type: "O",
                            description: gcalendar.description,
                            color: gcalendar.backgroundColor,
                            suspended: false
                          }

                          acted = { a, targetCalendar: null }

                          activatingCal.save render
                else
                  render()
  else
    res.redirect '/'

router.post '/settings/:calendarId', (req, res) ->
  email = req.session.email
  calendarId = decodeURIComponent(req.params.calendarId)
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.message
      else if !(~user.calendars.indexOf(calendarId))
        res.redirect '/?error=' + encodeURIComponent("Insufficient permissions")
      else
        # This is used so we can redirect when body elements aren't present which throw errors
        redirecterr = (error) ->
          urlPath = '/organization/settings/' + encodeURIComponent(calendarId)
          res.redirect urlPath + (if error then '?error=' + error.message else '?saved')

        saveCalendar = (error, calendar) ->
          if error?
            res.redirect '/?error=' + error.message
          else
            try
              calendar.name = req.body.name
              calendar.description = req.body.description
              calendar.slug = req.body.name.toLowerCase().replace(/[^a-z0-9]+/g, '-')
              
              newType = if types[req.body.type]? then req.body.type else "O"
              typechanged = newType isnt calendar.type
              calendar.type = newType

              if typechanged
                EventPartial
                .find { c: calendar }
                .setOptions { multi: true }
                .update { $set: { t: newType } }, (error) ->
                  if error? then redirecterr error
                  else
                    EventMetadata
                    .find { cal: calendar }
                    .setOptions { multi: true }
                    .update { $set: { t: newType } }, (error) ->
                      if error? then redirecterr error
                      else
                        calendar.save redirecterr

              else
                calendar.save redirecterr
              
            catch e
              redirecterr error
        
        Calendar.getCalendar calendarId, (error, calendar) ->
          if error?
            saveCalendar error
          
          else if calendar?
            # Calendar exists
            saveCalendar null, calendar

          else
            # Calendar not initiallized properly
            res.redirect('/organization/settings')
  else
    res.redirect '/auth/login'

# Normal organization settings page
router.get '/settings/:calendarId', (req, res) ->
  email = req.session.email
  calendarId = decodeURIComponent(req.params.calendarId)
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.message
      else if !(~user.calendars.indexOf(calendarId))
        res.redirect '/?error=' + encodeURIComponent("Insufficient permissions")
      else
        renderCalendarSettings = (error, calendar, isNew) ->
          if error?
            res.redirect '/?error=' + error.message
          else
            locals = {
              title: "Calendar Settings",
              types,
              isNew,
              calendarName: calendar.name,
              calendarSlug: calendar.slug,
              selectedType: calendar.type,
              calendarColor: calendar.color,
              calendarDescription: calendar.description
            }

            res.render "organization-settings-calendar-page", locals
        Calendar.getCalendar calendarId, (error, calendar) ->
          if error?
            renderCalendarSettings error
          else
            if calendar?
              isNew = false
              renderCalendarSettings null, calendar, isNew

            else
              # Calendar not initiallized properly
              renderCalendarSettings new Error "Calendar not initiallized!"

  else
    res.redirect '/'

module.exports = router