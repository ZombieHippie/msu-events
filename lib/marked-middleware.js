function setup (directory, pages) {

var express = require('express')
var router = express.Router()
var fs = require('fs')
var path = require('path')
var marked = require('marked')

var pagesDirectory = path.resolve(__dirname, '../pages/' + directory) + "/"
router.get('/', function (req, res) {
  res.render("markdown-middleware-index", { directory: directory, pages: pages })
})

router.get('/:view', function(req, res) {
  var view = req.params.view
  var fileName = pagesDirectory + view + ".md"
  fs.exists(fileName, function (viewExists) {
    if (viewExists)
    {
      var fileContentsMD = fs.readFileSync(fileName, "utf8")
      res.render("markdown-middleware", { html: marked(fileContentsMD) })
    }
    else
      res.redirect('/' + directory)
  })
})

return router

}

module.exports = setup
