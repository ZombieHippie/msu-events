express = require('express')
router = express.Router()

router.get '/', (req, res) ->
  stack = []
  res.render("error", { title: "test-organizations", message: "List of organizations", stack })

module.exports = router