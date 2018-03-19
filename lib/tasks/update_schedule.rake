namespace :schedule do

  task update_studios: :environment do |task|
    Studio.all.each do |studio|
      if studio.updated_at.nil? || studio.updated_at < Time.now - 21600
        provider = studio.schedule_url.split('.')[1].downcase.capitalize
        scraper_class = "Scraper::#{provider}".constantize
        puts "Updating schedule for #{studio.name}"

        begin
          scraper = scraper_class.new(studio.schedule_url)
          scraper.parse_classes
          scraper.studio.update(updated_at: Time.now)
        rescue => error
          puts error.message || error
          if error.message == '404 Not Found'
            puts "Removing studio #{studio.name}"
            studio.delete
            Filter.where(studio_id: studio.id).delete_all
          end
          next
        end
      end
    end
    invalidate_user_cache
  end

  task :update_studio, [:studio_id] => :environment do |task, args|
    studio = Studio.find(args[:studio_id])
    provider = studio.schedule_url.split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}".constantize
    puts "Updating schedule for #{studio.name}"

    scraper = scraper_class.new(studio.schedule_url)
    scraper.parse_classes
    studio.update(updated_at: Time.now)
  end

  def invalidate_user_cache
    User.all.each do |user|
      Rails.cache.delete("users/#{user.id}/suggested_classes")
    end
  end

  # Hobby dev db limit is 10k rows
  task free_storage: :environment do |task|
    num_classes = Klass.all.size
    if num_classes > 9000
      Klass.first(5000).each do |klass|
        klass.delete
      end
    end
  end
end
