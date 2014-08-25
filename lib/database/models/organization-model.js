// Organization Model
module.exports = {
  type: String, // Fraternity, Sorority, Intermural Sport, Interest Group, Campus
  info: {
    name: String, // Eg. Chi Alpha
    description: String,
    website: String,
    location: String
  },
  credentials: {
    hash: String,
    salt: String
  },
  calendars: Array
}