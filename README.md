# Fit Schedule
A Google Calendar-integrated app that lets you stay on top of your fitness schedule.


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
```

- Start the app with `rails s`, it should be available at `localhost:3000`

### Deploying to Heroku
- Create a new heroku remote and push to it:
```
$ heroku create [app name]
$ git push heroku master
```

- Set environment variables:
```
$ heroku config:set FS_GOOGLE_ID=[Google id]
                    FS_GOOGLE_SECRET=[Google secret]
```

- If assets are not showing up, precompile them:
```
$ heroku run assets:precompile
```
