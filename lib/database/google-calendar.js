google = require('googleapis')
API_KEY = "AIzaSyAXDm40LfDzsKJQUfHIrdGZwXWySh-2WAM"
CLIENT_ID = "162906317124-pj0hj65674u9o6arhvhecbgd6r5gq0u1.apps.googleusercontent.com"
PUBLIC_KEY = "14f017b3118f01299f534739884322c1936b1bd0"

module.exports = new google.calendar({ version: 'v3', auth: API_KEY })
module.exports.getOAuth = function (org) {
  return {
    response_type: "code",
    client_id: CLIENT_ID,
    redirect_uri: "localhost:3000/org/" + org + "/settings",
    access_type: "offline"
  }
}
