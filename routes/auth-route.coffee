express = require('express')
router = express.Router()
googleHook = require('../lib/database/google-calendar')
{ User } = require('../lib/database/database-mongoose')

saveTokens = (error, email, tokens) ->
  if error?
    console.log error
  else
    # console.log("\n")
    # console.log "saveTokens", email, Object.keys(tokens)

    User.getUser email, (error, user) ->
      if error?
        console.log error
        return

      if user?
        user.tokens = tokens
      else
        user = new User {
          tokens,
          email
        }
      user.save (err, user) ->
        # console.log err, user

router.get '/~google-oauth2', googleHook.handleOAuth2(saveTokens)

# After the user is logged in, the session.email is set then is redirected to here,
#   where the rest of the session is constructed
router.get '/set-session', (req, res) ->
  email = req.session.email
  if email?
    User.findOne({ email })
    .select 'picture name'
    .exec (error, user) ->
      if error?
        console.log "errror", error
      req.session.userName = user.name
      req.session.picture = user.picture
      res.redirect '/'
  else
    res.redirect '/'

router.get '/logout', (req, res) ->
  req.session.destroy(-> res.redirect '/')

router.get '/login', (req, res) ->
  res.redirect googleHook.getOAuthURL()

module.exports = router