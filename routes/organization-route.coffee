express = require('express')
router = express.Router()
async = require 'async'
{ User } = require '../lib/database/database-mongoose'
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


router.get '/refresh', (req, res) ->
  email = req.session.email
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.toString()
      else
        # Get auth for querying events
        auth = googleHook.getAuth user.tokens.access_token
        
        async.each(user.calendars, ((calendarId, nextCalendar) ->
            # Get event list
            listOptions = {
              auth,
              calendarId,
              fields: "description,items(description,end,htmlLink,iCalUID,id,location,recurrence,recurringEventId,start,status,summary,visibility),nextPageToken,nextSyncToken,summary,timeZone"
            }
            googleHook.getCalendar().events.list listOptions, (error, eventsList) ->
                if error?
                  nextCalendar(error)  
                else
                  console.log "eventsList", eventsList
                  nextCalendar()
          ), (error) ->
            if error?
              res.redirect '/?error=' + error.toString()
            else
              res.end("Updated Events")
        )
  else
    res.redirect '/'

router.post '/settings', (req, res) ->
  email = req.session.email
  if email?
    switch req.body.submit
      when "Update Calendars"
        calendars = []
        for calId, val of req.body when !!val
          calendars.push calId
        User.getUser email, (error, user) ->
          if error?
            res.redirect '/organization/settings/?error=' + error.toString()
          else
            user.calendars = calendars
            user.save (error) ->
              res.redirect '/organization/settings' + (if error then '?error=' + error.toString() else '?saved')
      when "Update Information"
        User.getUser email, (error, user) ->
          if error?
            res.redirect '/organization/settings/?error=' + error.toString()
          else
            user.name = req.body.name
            user.description = req.body.description
            user.slug = req.body.name.toLowerCase().replace(/[^a-z0-9]+/g, '-')
            user.type = if types[req.body.type]? then req.body.type else "O"

            user.save (error) ->
              res.redirect '/organization/settings' + (if error then '?error=' + error.toString() else '?saved')
      else
        console.log req.body
  else
    res.redirect '/auth/login'

# Normal organization settings page
router.get '/settings', (req, res) ->
  email = req.session.email
  if email?
    # Get token for email
    User.getUser email, (error, user) ->
      if error?
        res.redirect '/?error=' + error.toString()
      else
        # Get auth for querying calendars
        auth = googleHook.getAuth user.tokens.access_token
        
        # Get calendar list
        listOptions = {
          auth,
          minAccessRole: "owner",
          fields: "items(accessRole,backgroundColor,description,foregroundColor,id,location,summary,timeZone)"
        }
        googleHook.getCalendar().calendarList.list listOptions, (error, calendarList) ->
            if error?
              res.redirect '/?error=' + error.toString()
            else
              if user.calendars?
                for item in calendarList.items
                  item.checked = item.id in user.calendars

              locals = {
                title: "Organization Settings",
                types,
                userName: user.name,
                userSlug: user.slug,
                selectedType: user.type,
                userDescription: user.description,
                calendars: calendarList.items
              }

              res.render "organization-settings-page", locals
  else
    res.redirect '/'

module.exports = router