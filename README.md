MOState Events
======

This is a full application for indexing events from multiple Google Calendars, and displaying those events.

It has searching capabilities, and was originally built mobile-first with Bootstrap.

The core functionality of this code was developed October 2014.

# Screenshots

 * [Mobile First](#mobile-first)
 * [Browsing Calendars](#browsing-calendars)
 * [Organization Settings](#organization-settings)
   * [Suspending a Calendar](#suspending-a-calendar)
   * [Deleting a Calendar](#deleting-a-calendar)
   * [Editing a Calendar](#editing-a-calendar)
 * [Search Calendars and Events](#search-calendars-and-events)
 * [Application Tutorial Pages](#application-tutorial-pages)
 * [Calendar View](#calendar-view)
 * [Day View](#day-view)
 * [Week View](#week-view)

## Mobile First

Overview of App from Mobile View.

| Search Events | Browse Multiple Calendars |
| ----- | ---- |
| ![Mobile: Search for Events and Organizations "topics"](screenshots/mobile_search_query=topics.png) | ![Mobile: Browse View](screenshots/mobile_browse_filter=open.png) |
| ![Mobile: Week View](screenshots/mobile_week_1.png) | ![Mobile: Day View](screenshots/mobile_day_1.png) |


## Browsing Calendars

We can view all calendars which are indexed by the application.

![Browse](screenshots/browse_1.png)

## Organization Settings

Setting up and configuring organization.

**Control Panel**

![Organization Settings control Panel](screenshots/organization_settings_1.png)
![View of Calendar Settings from Desktop](screenshots/organization_settings_desktop.png)

### Suspending a Calendar

Suspending a calendar allows operators to keep track of the events and continue to keep indexes up to date,
but removes the events from being searchable or findable.
![Organization Setting Option: Suspend](screenshots/organization_settings_option=suspend_1.png)

### Deleting a Calendar

Delete all data related to this calendar.

![Organization Setting Option: Delete](screenshots/organization_settings_option=delete_1.png)

### Editing a Calendar

We can rename and categorize calendars.

![Editing the Peanut Butter and Jelly Club Calendar](screenshots/organization_settings_peanut-butter-jelly-club_1.png)
![Editing the Computer Science Club Calendar](screenshots/organization_settings_computer-science-club_1.png)

![Editing the Covalent Grind Calendar](screenshots/organization_settings_covalent-grind_1.png)

## Search Calendars and Events

We create an index of all events and organization's titles and descriptions to be queried.

![Searching for Events and Organizations "pb"](screenshots/search_pb_1.png)

## Application Tutorial Pages

Provided in the application are instructions for Organizations to add their calendars through the Admin.

![How to Create a Calendar](screenshots/pages_tutorial_create_1.png)
![How to Submit a Calendar](screenshots/pages_tutorial_submit_1.png)
![How to Submit a Calendar page 2](screenshots/pages_tutorial_submit_2.png)

## Calendar View

In this view, when we click "subscribe" to the calendar, it directs us to
our Google Calendar settings page, and adds the calendar to our calendars.

For this to work, the calendar must be available to public.
![Viewing Events from the Covalent Social Events Calendar](screenshots/calendar_covalent-social-events_1.png)

## Day View

All Events happening during the selected day.

![](screenshots/day_page=3_1-event.png)
![](screenshots/day_page=10.png)

![](screenshots/day_page=10_1-event.png)

## Week View

All Events happening during the selected week.

![](screenshots/week_0.png)
![](screenshots/week_1.png)
![](screenshots/week_1_alt.png)
![](screenshots/week_1_scroll1.png)
![](screenshots/week_1_scroll2.png)

**Applying filters to Events**

![Week with Filters open](screenshots/week_no-filter_1.png)

Here, we have narrowed down our selection to just `Academic` categorized calendars.
![Week with Filter: Academic](screenshots/week_filter=academic_1.png)




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
