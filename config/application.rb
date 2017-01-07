require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Fitschedule
  class Application < Rails::Application
    config.autoload_paths += Dir["#{config.root}/lib",
                                 "#{config.root}/lib/**/"]

    config.active_record.raise_in_transactional_callbacks = true
    Rails.logger = Logger.new(STDOUT)
  end
end
