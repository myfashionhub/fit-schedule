# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Scrape FitReserve studios
html = File.read("#{Rails.root}/lib/assets/fitreserve.html")
page = Nokogiri::HTML(html)

page.css('.studio-partner-link a').each do |studio|
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
