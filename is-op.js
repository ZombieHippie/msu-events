
var ops = require('fs').readFileSync(__dirname + "/ops.txt", "utf8").split(/[\s\r\n]+/)

console.log(ops)

exports.isOp = function (email) {
  console.log(email)
  try {
    return !!(~ops.indexOf(email.trim().toLowerCase()))
  } catch (error) {
    return false
  }
}
