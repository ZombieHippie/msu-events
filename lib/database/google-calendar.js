var google = require('googleapis')
var OAuth2Client = google.auth.OAuth2
var OAuth2 = google.oauth2('v2')
var Calendar = google.calendar
var isOp = require('../../is-op').isOp

var CLIENT_ID = "162906317124-lvso92rfufijf1o8tcvkkpm79qq3alv6.apps.googleusercontent.com"
var CLIENT_SECRET = "P5hs0YpDtd7fFaKv5hZoadKS"
var REDIRECT_URL = "http://localhost:3000/auth/~google-oauth2"


// exports.getAuthOrRefresh

exports.getAuth = function (token) {
  var ACCESS_TOKEN = token
  var oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

  oauth2Client.setCredentials({
    access_token: ACCESS_TOKEN
  })

  return oauth2Client
}

exports.getCalendar = function () {
  return new Calendar({ version: 'v3' })
}

var accessors = {}

exports.getOAuthURL = function () {
  // Create access security token
  var token
  do {
    token = (Math.random()).toString(33).slice(3, 18)
  }
  while(accessors[token] != null)

  accessors[token] = Date.now() + 10 * 60 * 1000

  oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)
  return oauth2Client.generateAuthUrl({
    response_type: "code",
    access_type: "offline",
    scope: "https://www.googleapis.com/auth/calendar.readonly https://www.googleapis.com/auth/userinfo.email",
    include_granted_scopes: true,
    state: encodeURIComponent(token)
  })
}

// callback is for associating successful calendars
exports.handleOAuth2 = function (callback) {
  return function (req, res) {
    var token = decodeURIComponent(req.query.state)

    // Check if state token is valid 
    if (accessors[token] != null) {
      delete accessors[token]

      oauth2Client = new OAuth2Client(CLIENT_ID, CLIENT_SECRET, REDIRECT_URL)

      oauth2Client.getToken(req.query.code, function(err, tokens) {

        oauth2Client.setCredentials(tokens)
        
        OAuth2.userinfo.get({ userid: "me", auth: oauth2Client}, function (err, userinfo) {
          if (err != null) {
            callback(err)
            res.redirect('/')
          } else {
            if (isOp(userinfo.email)) {
              // Store eligible user
              callback(null, userinfo.email, tokens)

              req.session.email = userinfo.email

              res.redirect('/auth/set-session')

            } else {
              res.end('Your email address does not have sufficient permissions at this time.')
            }
          }
        })
      })
    } else {
      res.redirect('/')
    }
  }
}
