express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  stack = []
  res.render("error", { title: "test-calendars", message: "List of calendars", stack })

module.exports = router