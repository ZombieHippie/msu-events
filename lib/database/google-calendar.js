google = require('googleapis')
API_KEY = "AIzaSyAXDm40LfDzsKJQUfHIrdGZwXWySh-2WAM"
module.exports = new google.calendar({ version: 'v3', auth: API_KEY })
