var express = require('express')
var router = express.Router()
var fs = require('fs')
var path = require('path')

var views = fs.readdirSync(path.resolve(__dirname, '../views')).map(function (E) {return "/test/" + E })

router.get('/', function (req, res) {
  res.render("test", { view: "test", views: views  })
})

router.get('/:view', function(req, res) {
  var view = req.params.view

  fs.exists('./views/' + view, function (viewExists) {
    if (viewExists)
      res.render(view, { view: view.slice(0,-5), views: views })
    else
      res.redirect('/test')
  })
})

module.exports = router
