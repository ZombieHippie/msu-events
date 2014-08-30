var google = require('googleapis')
var OAuth2Client = google.auth.OAuth2
var Calendar = google.calendar

var CLIENT_ID = "162906317124-lvso92rfufijf1o8tcvkkpm79qq3alv6.apps.googleusercontent.com"
var CLIENT_SECRET = "P5hs0YpDtd7fFaKv5hZoadKS"
var REDIRECT_URL = "http://localhost:3000/org/~google-oauth"

var orgAuths = {
  'the-pb-j-club': {
    code: "ACCESS TOKEN HERE"
  }
}

exports.getAuth = function (orgSlug) {
  var auth = orgAuths[orgSlug]
  var ACCESS_TOKEN = auth.code
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

exports.getOAuthParameters = function (org) {
  // Create access security token
  var token
  do {
    token = (Math.random()).toString(33).slice(3, 18)
  }
  while(accessors[token] != null)

  accessors[token] = Date.now() + 10 * 60 * 1000

  return {
    response_type: "code",
    client_id: CLIENT_ID,
    redirect_uri: REDIRECT_URL,
    access_type: "offline",
    scope: encodeURIComponent("https://www.googleapis.com/auth/calendar.readonly"),
    state: encodeURIComponent(
      JSON.stringify({
        org: org,
        token: token
      })
    )
  }
}

exports.handleOAuth2 = function (req, res) {
  console.log(req.query)
  var state = JSON.parse(decodeURIComponent(req.query.state))
  console.log(accessors[state.token], Date.now())
  res.redirect('/org/' + state.org)
}
