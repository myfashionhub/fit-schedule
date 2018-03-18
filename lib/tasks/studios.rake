namespace :studios do
  task :scrape_fitreserve => :environment do |task|
    html = File.read("#{Rails.root}/lib/assets/fitreserve.html")
    page = Nokogiri::HTML(html)

    page.css('.row.studios .name a').each do |studio|
      name = studio.text
      url = "https://www.fitreserve.com#{studio['href']}"
      studio = Studio.find_by(schedule_url: url)

      if studio.nil?
        studio = Studio.create(name: name, schedule_url: url)
        puts "Created studio #{studio.name}"
      else
        puts "#{studio.name} already exists"
      end
    end
  end

  task clean_data: :environment do |task|
    studio_ids = Filter.all.pluck(:studio_id).uniq
    studio_ids.each do |studio_id|
      begin
        Studio.find(studio_id)
      rescue => e
        puts "Removing filters for studio #{studio_id}"
        Filter.where(studio_id: studio_id).delete_all
      end
    end
  end
end
