Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    {
      :timeout => 2
    }
  )
end
