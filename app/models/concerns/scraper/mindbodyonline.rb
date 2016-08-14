require 'capybara/poltergeist'

module Scraper
  class Mindbodyonline
    attr_reader    :url, :session, :page,
                   :studio, :classes

    def initialize(url, studio=nil)
      @url     = url
      @session = Capybara::Session.new(:poltergeist)
      @session.driver.browser.js_errors = false
      @session.visit url
      sleep 2

      @page = @session.within_frame 'mainFrame' do
        Nokogiri::HTML(@session.html)
      end
      @studio  = studio
      @classes = []
    end

    def parse_classes
      studio = studio || Studio.find_by(schedule_url: url)
      page.css('#classSchedule-mainTable').css('tr')
      date = nil

      rows.each do |row|
        next unless row.present?

        begin
          is_date = Date.parse(row.text) rescue nil
          data_name = row.children.first.attributes['class'].value rescue ''

          if data_name == 'header' && is_date
            date = row.text
          else
            if !row.text.downcase.include?('start time')
              cols = row.css('td')

              next if cols[1].blank?
                      #|| cols[1].text.empty? ||
                      #cols[1].text.downcase.include?('0 open')
              start_time = cols[0].text.gsub("\u00A0", " ").strip.upcase
              duration   = cols[5].text.gsub("\u00A0", " ").strip
              times      = get_times(start_time, duration)

              klass = {
                date:       Date.parse(date.gsub("\u00A0", " ").strip),
                start_time: start_time,
                end_time:   times[:end_time],
                name:       cols[2].text.gsub("\u00A0", " ").strip,
                instructor: cols[3].text.gsub("\u00A0", " ").strip,
                #room:       cols[4].text.gsub("\u00A0", " ").strip,
                duration:   times[:duration],
                studio_id:  @studio.id
              }

              classes.push( Klass.create_from_raw(klass) )
            end
          end
        rescue => error
          Rails.logger.error("#{error}, row '#{row.text}'")
        end
      end
      classes
    end

    def parse_studio
      studio_name = session.title.sub(" Online","")
      Studio.find_or_create_by(
        name: studio_name,
        schedule_url: url
      )
    end

    def navigate(url, session)
      # if no monday, saturday, click week toggle
      #session.find('#week-tog-c').click
      session.click_link('#week-arrow-r')
    end

    def get_times(start_time, duration)
      start_hour = start_time.split(' ')[0].split(':')[0].to_i
      start_mins = start_time.split(' ')[0].split(':')[1].to_i
      duration_hour = duration.scan(/\d\shour/)[0].split(' ')[0].to_i
      duration_mins = duration.scan(/\d+\smin/)[0].split(' ')[0].to_i rescue 0

      end_hour = start_hour + duration_hour + duration_mins % 60
      end_mins = duration_mins - (duration_mins % 60)
      end_mins = end_mins > 9 ? end_mins.to_s : "0#{end_mins}"

      start_modifier = start_time.split(' ')[1]
      if start_hour < 12 && start_modifier == 'AM' && end_hour >= 12
        end_modifier = 'PM'
      else
        end_modifier = start_modifier
      end

      end_hour = end_hour % 12 if end_hour > 12
      end_time = "#{end_hour}:#{end_mins} #{end_modifier}"
      duration = duration_hour * 60 + duration_mins
      { end_time: end_time, duration: duration }
    end
  end

end
