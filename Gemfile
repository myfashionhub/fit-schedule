source 'https://rubygems.org'
ruby '2.5.5'

gem 'bundler', '1.15.2'
gem 'rails', '5.1.0' # For compatability w Google API client

group :development, :test do
  gem 'byebug'
  gem 'pry'
  gem 'pry-nav'  
  gem 'dotenv-rails', '2.7.2'
end

group :production do
  gem 'pg', '~> 0.18'
  gem 'rails_12factor'
end

# Frontend
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'underscore-rails'

# Third-party
gem 'clockwork'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'google-api-client', '~> 0.9.0'
gem 'signet' # Auth object for Google API client

# Scraping
gem 'nokogiri'
gem 'capybara'
gem 'poltergeist'
gem 'phantomjs'
