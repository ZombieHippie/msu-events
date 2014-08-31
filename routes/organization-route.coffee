express = require('express')
router = express.Router()
{ User } = require '../lib/database/database-mongoose'
googleHook = require('../lib/database/google-calendar')

router.get '/', (req, res) ->
  res.redirect('/')

router.post '/settings', (req, res) ->
  email = req.session.email
  if email?
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
              res.render "organization-settings-page", { title: "Organization Settings", calendars: calendarList.items }
  else
    res.redirect '/'

module.exports = router