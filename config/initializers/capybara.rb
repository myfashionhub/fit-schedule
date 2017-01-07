Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    {
      timeout: 20,
      js_errors: false
    }
  )
end
