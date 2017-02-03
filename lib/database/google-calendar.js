const google = require('googleapis')

google.options({ })

var OAuth2 = google.oauth2('v2')
var isOp = require('../../is-op').isOp

const ENV = require('../../env')
console.log(ENV)
const REDIRECT_URL = ENV.HOST + "/auth/~google-oauth2"

// exports.getAuthOrRefresh

// Helper to create OAuth2 Client
function createOAuthClient() {
  return new google.auth.OAuth2(ENV.CLIENT_ID, ENV.CLIENT_SECRET, REDIRECT_URL)
}

exports.getAuth = function (access_token) {
  // Access token provided from logging in.
  var oauth2Client = createOAuthClient()

  oauth2Client.setCredentials({
    access_token: access_token
  })

  return oauth2Client
}

exports.getCalendar = function () {
  return google.calendar({ version: 'v3' })
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

  oauth2Client = createOAuthClient()

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

      oauth2Client = createOAuthClient()

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
