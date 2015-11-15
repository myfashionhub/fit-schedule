class Filter < ActiveRecord::Base
  belongs_to :user
  belongs_to :studio

  validates_uniqueness_of :class_name, scope: [:studio_id, :user_id]
  
  def self.create_from_raw(filter_obj, studio_id, user_id)
    Filter.find_or_create_by({
      user_id:    user_id,
      studio_id:  studio_id,
      class_name: filter_obj['class_name']
    })
  end

  def self.update_user_preferences(params, user)
    filters = JSON.parse(params[:filters])

    filters.each do |filter_obj|
      Filter.create_from_raw(filter_obj, params[:studio_id], user.id)
    end
  end

  def self.suggest_classes(user, studio_id)
    if user.calendar_id
      calendar = Calendar.new(user.google_token)
      events = calendar.list_events(user.calendar_id)
      classes = Filter.get_preferences(user.id, studio_id)

      return { error: 'Google token expired' } if !events

      results = []
      classes.each do |klass|
        date_str   = klass.date.to_date.to_s
        start_time = time_to_datetime(klass.start_time, date_str)
        end_time   = time_to_datetime(klass.end_time, date_str)

        weekday = JSON.parse(user.availability).detect do |day|
          day['day'] == klass.date.wday
        end

        no_conflict = time_to_24hrs(klass.start_time) > weekday['end_time'] &&
                      time_to_24hrs(klass.end_time) < weekday['start_time'] rescue true

        events.each_with_index do |event, i|
          if ( klass.date.to_date == event[:start_time].to_date ||
               klass.date.to_date == event[:end_time].to_date ) &&
             i < events.length
            results.push(klass) if no_conflict &&
                                   start_time > event[:end_time] &&
                                   end_time < events[i+1][:start_time]
          end
        end
      end

      results
    else
      { error: "User has not specified a Google calendar." }
    end
  end

  def self.get_preferences(user_id, studio_id)
    class_names = Filter.where(user_id: user_id, studio_id: studio_id).
                    pluck(:class_name).uniq

    classes = []
    Klass.where(studio_id: studio_id).each do |klass|
      class_names.each do |name|
        classes.push(klass) if klass.name == name && klass.date >= Time.now
      end
    end

    classes
  end


  # Helper

  def self.time_to_datetime(time_str, date_str)
    time_str = time_to_24hrs(time_str)
    Time.parse(date_str + ' ' + time_str)
  end

  def self.time_to_24hrs(time_str)
    if time_str.include?('12') && time_str.include?('PM')
      time_str.split(' ').first
    else
      if time_str.include?('PM')
        time = time_str.split(' ').first
        hour = ( time.split(':').first ).to_i + 12
        hour.to_s+ ':' + time.split(':').last
      else
        time_str.split(' ').first
      end
    end
  end

end
