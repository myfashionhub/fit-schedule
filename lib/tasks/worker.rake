namespace :worker do

  task update_schedules: :environment do |task|
    Studio.all.each do |studio|
      provider = studio.schedule_url.split('.')[1].downcase.capitalize
      scraper_class = "Scraper::#{provider}".constantize
      puts "Updating schedule for #{studio.name}."

      result = scraper_class.get_classes(studio.schedule_url)
      classes = Klass.create_from_raw(result)
      studio.update(updated_at: Time.now)
    end
  end

end
