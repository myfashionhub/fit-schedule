namespace :schedule do
  # Helper methods
  def scrape_studio(studio)
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
    end
  end

  def invalidate_user_cache
    User.all.each do |user|
      Rails.cache.delete("users/#{user.id}/suggested_classes")
    end
  end

  # Task definitions
  task :scrape_studio_classes => :environment do |task, args|
    Studio.all.each do |studio|
      scrape_studio(studio)
    end
  end

  task update_studio_schedule: :environment do |task|
    # Only update studios with filters
    # to avoid filling up db rows (limit 10k)
    studios_to_update = Studio.all.select do |studio|
      Filter.where(studio_id: studio.id).size > 0
    end

    studios_to_update.each do |studio|
      if studio.updated_at.nil? || studio.updated_at < Time.now - 21600
        scrape_studio(studio)
      end
    end

    invalidate_user_cache
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
