require 'capybara/poltergeist'

module Scraper

  class Mindbodyonline

    def self.get_classes(url)
      session = Capybara::Session.new(:poltergeist)
      session.visit url
      sleep 2

      navigate(url, session)

      studio_name = session.title.sub(" Online","")
      page = session.within_frame 'mainFrame' do
        Nokogiri::HTML(session.html)
      end

      classes = []
      date = nil

      rows = page.css('#classSchedule-mainTable').css('tr')
      rows.each do |row|
        begin
          is_date = Date.parse(row.text) rescue nil
          data_name = row.children.first.attributes['class'].value rescue ''

          if data_name == 'header' && is_date
            date = row.text
          else
            if !row.text.downcase.include?('start time')
              cols = row.css('td')

              klass = {
                date:       date.gsub("\u00A0", "").strip,
                start_time: cols[0].text.gsub("\u00A0", "").strip,
                name:       cols[2].text.gsub("\u00A0", "").strip,
                instructor: cols[3].text.gsub("\u00A0", "").strip,
                room:       cols[4].text.gsub("\u00A0", "").strip,
                duration:   cols[5].text.gsub("\u00A0", "").strip
              }

              classes.push(klass)
            end
          end
        rescue => error
          Rails.logger.error("#{error}, row '#{row.text}'")
        end
      end

      { studio_name: studio_name, classes: classes }
    end

    def self.navigate(url, session)
      if url.index('851') > -1
        binding.pry
        #session.find('#tabTD10').click
        session.find('a', :text => 'AILEY EXTENSION').click
        sleep 1
        session.find('#week-tog-c').click
      end
    end
  end

end
