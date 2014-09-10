require('coffee-script/register') // Needed to require modules written in coffee-script
var express = require('express')
var path = require('path')
var cookieParser = require('cookie-parser')
var bodyParser = require('body-parser')
var session = require('express-session')

var production = false

var testRoute = require('./routes/test.js')

var app = express()

// view engine setup
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'jade')

// Form data access
app.use(bodyParser.json())
app.use(bodyParser.urlencoded())

app.use(cookieParser())
app.use(session({
    secret: 'such secretz'
}))
app.use(require('./lib/coffee-middleware')({
    src: __dirname + '/static/coffee',
    prefix: '/coffee'
}))

/// Preliminary locals for jade
app.use(function (req, res, next) {
    // Production mode hides login buttons at this time
    res.locals.production = production

    // User information display
    if (req.session.email != null) {
        res.locals.email = req.session.email
        res.locals.picture = req.session.picture
        res.locals.calendars = req.session.calendars
    }

    next()
})

/// Pages
var markedMw = require('./lib/marked-middleware.js')
tutorialPages = [
    {
        name: "create-google-calendar",
        disp: "How to create a new Google Calendar",
        description: "Learn how to create a calendar for organizing your organizations events."
    },
    {
        name: "linking-google-calendar-with-your-organization",
        disp: "How to link an existing Google Calendar with your organization",
        description: "Learn how to link an existing Google Calendar with your organization."
    }
]
app.use('/tutorials', markedMw('tutorials', tutorialPages))
aboutPages = [
    {
        name: "us",
        disp: "About the Missouri State Events service",
        description: "Learn more about the history of this service"
    },
    {
        name: "community",
        disp: "How Missouri State Events will benefit your community",
        description: "Learn how this service will help connect our students together, and promote your groups' events."
    }
]
app.use('/about', markedMw('about', aboutPages))

/// Routes
app.use('/test', testRoute)
app.use('/auth', require('./routes/auth-route.coffee'))
app.use('/organization', require('./routes/organization-route.coffee'))
// app.use('/test-calendars', require('./routes/test-calendars.coffee'))
// app.use('/test-organizations', require('./routes/test-organizations.coffee'))

app.use('/contact', function (req, res, next) {
    var notImplented = new Error("Sorry, contact isn't ready yet :-(")
    notImplented.status = 501
    next(notImplented) 
})

app.use(express.static(path.join(__dirname, 'static')))

/// catch 404 and forward to error handler
app.use(function(req, res, next) {
    var err = new Error('Not Found')
    err.status = 404
    next(err)
})

/// error handlers

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
        res.status(err.status || 500)
        res.render('error', {
            //error: err
        })
    })
}

// production error handler
// no stacktraces leaked to user
app.use(function(err, req, res, next) {
    res.status(err.status || 500)
    res.render('error', {
        message: err.message,
        error: {}
    })
})


module.exports = app
