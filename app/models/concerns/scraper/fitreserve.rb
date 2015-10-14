require 'open-uri'

module Scraper

  class Fitreserve

    def self.get_classes(url)
      page = Nokogiri::HTML(open(url))

      studio_name = page.css('.details .name').text
      logo = page.css('.details .logo').last.attributes['src'].value
      address = page.css('.details .address').text.strip.gsub("\n",' ')
      studio = Studio.find_or_create_by({
        name:         studio_name,
        schedule_url: url,
        address:      address,
        logo:         logo
      })

      classes = []
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
              duration:   time[:duration]
            }  

            classes.push(klass)
          end
        end       
      end

      { studio: studio, classes: classes }
    end

    def self.parse_time(str)
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

    def self.parse_date(date_string)
      date = date_string.split(', ').last
      month = Date.parse(date).strftime('%m')
      current_year = Date.today.strftime('%Y')
      current_month = Date.today.strftime('%m')

      if current_month == '12' && month == '1'
        year = (current_year.to_i + 1).to_s
      else
        year = current_year
      end

      Date.parse(date + ' ' + year)
    end

    def self.format_class(class_string)
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

=begin
 # parse class level   
      level = ''; type  = ''
      array = class_string.split(' - ')

      [ 
        'intro to',  'open level', 'open', /levels?\s\d(.+||)/
      ].each do |level_regex|
        match = array.last.downcase.match(level_regex)
        if match
          level = match[0]
          break
        end
      end

      if array.length > 1
        type = array.first.downcase
      else
        type = array.first.downcase.gsub(level, '').strip
      end

      { type: type.capitalize, level: sanitize_level(level) }
=end
