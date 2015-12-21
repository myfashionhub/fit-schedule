namespace :worker do

  task update_schedules: :environment do |task|
    Studio.all.each do |studio|
      if studio.updated_at.nil? || studio.updated_at < Time.now - 21600
        provider = studio.schedule_url.split('.')[1].downcase.capitalize
        scraper_class = "Scraper::#{provider}".constantize
        puts "Updating schedule for #{studio.name}"

        result = scraper_class.get_classes(studio.schedule_url)
        classes = Klass.create_from_raw(result)
        studio.update(updated_at: Time.now)
      end
    end
  end

  task :update_schedule, [:studio_id] => :environment do |task, args|
    studio = Studio.find(args[:studio_id])
    provider = studio.schedule_url.split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}".constantize
    puts "Updating schedule for #{studio.name}"

    result = scraper_class.get_classes(studio.schedule_url)
    classes = Klass.create_from_raw(result)
    studio.update(updated_at: Time.now)
  end
end
