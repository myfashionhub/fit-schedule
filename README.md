# Fit Schedule
A Google Calendar-integrated app that lets you stay on top of your fitness schedule.

## How it works
- User signs in with Google and gives FitSchedule access to the calendar (this request is handled by omniauth and omniauth-google-oauth2).

- User pastes a schedule URL from FitReserve or MindBody Online. The app scrapes the page for the schedule, and shows users all the class types to choose from.
  + FitReserve is scraped using [Nokogiri](https://github.com/myfashionhub/fit-schedule/blob/master/app/models/concerns/scraper/fitreserve.rb).

  + MindBody Online page is opened in a headless browser by [Poltegeist](https://github.com/myfashionhub/fit-schedule/blob/master/app/models/concerns/scraper/mindbodyonline.rb), a PhantomJS driver for Capybara. Then the page's HTML can be parsed by Nokogiri.

- The [Calendar class](https://github.com/myfashionhub/fit-schedule/blob/master/app/models/calendar.rb), a non-ActiveRecord model used to handle interactions with the Google Calendar API, obtains events in the user's calendar.

- When the user goes on their schedule page, they can [view all the classes](https://github.com/myfashionhub/fit-schedule/blob/master/app/controllers/filters_controller.rb) that match their preferences and do not conflict with appointments they already have on the calendar. ([Filter logic](https://github.com/myfashionhub/fit-schedule/blob/master/app/models/filter.rb))

- User can choose the classes he/she desires and saves it as an appointment.

![fitschedule-preferences](https://cloud.githubusercontent.com/assets/7177481/14097909/8532f09a-f544-11e5-965c-3421492fb136.png)

![fitschedule-schedule](https://cloud.githubusercontent.com/assets/7177481/14097910/85345e58-f544-11e5-8b24-eee81d082fea.png)

### Planned features
- Invalidate cache when user adds new studios or filters.
- Sync the appointments to Google Calendar.
- Renew Google token offline to keep user signed in.
- Scrape classes on ClassPass.

### Getting started

- Clone the repo, create the database:
```$ rake db:create db:migrate```

- Obtain Google client id and secret:
  + In the [Google Developer Console](https://console.developers.google.com), create a new project.
  
  + Under *APIs & auth > API*, enable the Google+ API and Calendar API

  + Under *APIs & auth > Credentials*, add to *Authorized redirect URIs* your callback URLs, i.e. `http://localhost:3000/auth/google_oauth2/callback`. (Add one for each environment if they have different hostname.)

- Add environment variables in a `.env` file in the project root:
```
FS_GOOGLE_ID=
FS_GOOGLE_SECRET=
API_URL=localhost:3000
```

- Start the app with `rails s`, it should be available at `localhost:3000`

### Deploying to Heroku
- Create a new heroku remote and push to it:
```
$ heroku create [app name]
$ git push heroku master
```

- Create the database:
```
$ heroku run rake db:create db:migrate
```

- Set environment variables:
```
$ heroku config:set FS_GOOGLE_ID=[Google id]
                    FS_GOOGLE_SECRET=[Google secret]
                    API_URL=[Heroku app URL]
```

- If assets are not showing up, precompile them:
```
$ heroku run assets:precompile
```

- Add buildpacks for Nodejs and PhantomJS
```
heroku buildpacks:add --index 1 heroku/nodejs
heroku buildpacks:add  https://github.com/stomita/heroku-buildpack-phantomjs
```

- Add web process for Procfile
```
web: bin/rails server -p $PORT -e $RAILS_ENV
```

- Add package.json to specify Node version
