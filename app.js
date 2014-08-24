require('coffee-script/register') // Needed to require modules written in coffee-script
var express = require('express')
var path = require('path')
var cookieParser = require('cookie-parser')
var bodyParser = require('body-parser')
var session = require('express-session')

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

/// Routes
app.use('/test', testRoute)
app.use('/test-calendars', require('./routes/test-calendars.coffee'))
app.use('/test-organizations', require('./routes/test-organizations.coffee'))

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
            error: err
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
