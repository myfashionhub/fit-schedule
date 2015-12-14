Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, 
  ENV['FS_GOOGLE_ID'],
  ENV['FS_GOOGLE_SECRET'],
  {    
    access_type: 'offline',
    scope: 'https://www.googleapis.com/auth/userinfo.email,https://www.googleapis.com/auth/calendar',
    redirect_uri: ENV['API_URL']+'/auth/google_oauth2/callback'
  }
end
