MOState Events
======

## Getting Started

Clone Repository, and install Mongodb (which we will use for our database).

Define a dev env variables file like `./dev.sh` that has contents similar to:

```sh
export ME_CLIENT_ID="956326957622-6emv3ttljhf34dcpaq2r92phs3e38kjd.apps.googleusercontent.com"
export ME_CLIENT_SECRET="CvAPPpuyixy_bghAQ34pB6eN"

# Ensure your callback URL in your Google APIs console is like: $ME_HOST/auth/~google-oauth2
# Example: https://msu-events.ngrok.io/auth/~google-oauth2
export ME_HOST="https://msu-events.ngrok.io"

export ME_OP="your-google-account-email@gmail.com"
```

Then, we can execute our app using `source ./dev.sh && npm start`

## Tutorials
 * [Creating your Google Calendar](/pages/tutorials/create-google-calendar.md)
 * [Submitting your Google Calendar](/pages/tutorials/submitting-your-google-calendar.md)
 * [Linking Google Calendar with your organization](/pages/tutorials/linking-google-calendar-with-your-organization.md)
