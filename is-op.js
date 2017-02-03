/**
 * This file can be updated to provide a different way to check the Operators status
 * of an email account.
 * 
 * Operators may manage the indexing of events and accepting organizations.
 */
const file_ops = require('fs').readFileSync(__dirname + "/ops.txt", "utf8").split(/[\s\r\n]+/)
const env_op = require('./env').OP
const ops = [ env_op ].concat(file_ops)

console.log("Operators:", ops)

exports.isOp = function (email) {
  console.log(email)
  try {
    return !!(~ops.indexOf(email.trim().toLowerCase()))
  } catch (error) {
    return false
  }
}
