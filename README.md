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
