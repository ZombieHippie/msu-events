var express = require('express')
var router = express.Router()
var fs = require('fs')
var path = require('path')

var views = fs.readdirSync(path.resolve(__dirname, '../views'))

router.get('/', function (req, res) {
  console.log("hello test")
  res.render("test", { view: "test", views: views  })
})

router.get('/:view', function(req, res) {
  var view = req.params.view

  fs.exists('./views/' + view + '.jade', function (viewExists) {
    if (viewExists && view !== "test")
      res.render(view, { view: view, views: views })
    else
      res.redirect('/test')
  })
})

module.exports = router
