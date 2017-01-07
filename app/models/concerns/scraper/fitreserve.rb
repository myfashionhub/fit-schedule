require 'open-uri'

module Scraper

  class Fitreserve
    attr_reader   :url, :page, :studio, :classes

    def initialize(url, studio=nil)
      @url  = url
      @page = Nokogiri::HTML(open(url))
      @studio  = studio
      @classes = []
    end

    def parse_classes
      page.css('.row.schedule').each do |day|
        date = parse_date(day.css('.date').text)

        day.css('tr').each do |row| 
          time_string = row.css('.time').text

          if time_string.downcase != 'time' &&
             row.css('.reserve a').text.downcase == 'reserve' 
            time = parse_time(time_string.split(' - '))

            klass = {
              date: date,
              start_time: time[:start_time],
              end_time:   time[:end_time],
              name:       format_class(row.css('.name').text),
              instructor: row.css('.instructor').text,
              duration:   time[:duration],
              studio_id:  studio.id
            }

            classes.push(Klass.create_from_raw(klass))
          end
        end       
      end
      classes
    end

    def parse_studio
      studio = Studio.find_by(schedule_url: url)

      if !studio
        name = page.css('.details .name').text
        logo = page.css('.details .logo').last.attributes['src'].value
        address = page.css('.details .address').text.strip.gsub("\n",' ')

        studio = Studio.create(
          name:         name,
          schedule_url: url,
          address:      address,
          logo:         logo
        )
      end
      studio
    end

    def parse_time(str)
      end_modifier = str.last.split(' ').last
      end_time     = Time.parse(str.last)
      start_time   = Time.parse(str.first + ' ' + end_modifier)

      duration = (end_time - start_time) / 60
      if duration > 200 || duration < 0
        start_modifier = end_modifier == 'PM' ? 'AM' : 'PM'
        start_time = Time.parse(str.first + ' ' + start_modifier)
        duration = (end_time - start_time) / 60
      end
      
      {
        start_time: start_time.strftime('%l:%M %p').strip,
        end_time:   end_time.strftime('%l:%M %p').strip,
        duration:   duration
      }
    end

    def parse_date(date_string)
      date = date_string.split(', ').last
      month = Date.parse(date).strftime('%m')
      current_year = Date.today.strftime('%Y')
      current_month = Date.today.strftime('%m')

      if current_month == '12' && month == '01'
        year = (current_year.to_i + 1).to_s
      else
        year = current_year
      end

      Date.parse(date + ' ' + year)
    end

    def format_class(class_string)
      matches = class_string.downcase!.capitalize!.scan(/\W[a-z]/)
      matches.each do |letter|
        class_string.gsub!(letter, letter.upcase)
      end

      class_string
    end

    def self.sanitize_level(level)
      level.gsub(' to','').gsub(')','').capitalize
    end

  end

end
