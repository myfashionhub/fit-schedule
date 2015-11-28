class Filter < ActiveRecord::Base
  belongs_to :user,   inverse_of: :filters
  belongs_to :studio

  validates_uniqueness_of :class_name, scope: [:studio_id, :user_id]


  def self.update_user_preferences(params, user)
    class_names = JSON.parse(params[:class_names])
    user_filters = Filter.where(user_id: user.id, studio_id: params[:studio_id])

    class_names.each do |class_name|
      existing_filter = user_filters.detect do |filter|
        filter.class_name == class_name
      end

      if existing_filter.blank?
        Filter.find_or_create_by({
          user_id:    user.id,
          studio_id:  params[:studio_id],
          class_name: class_name
        })
      end
    end

    user_filters.each do |filter|
      filter.destroy if class_names.index(filter.class_name).nil?
    end
  end

  def self.suggest_classes(user, studio_id)
    if user.calendar_id.present?
      calendar = Calendar.new(user.google_token)
      events = calendar.list_events(user.calendar_id)
      studio = Studio.find(studio_id)
      classes = Filter.match_classes(user.id, studio_id)

      return { error: 'Google token expired' } if !events

      classes = classes.select { |klass| no_conflict(klass, user, events) }
      classes.map { |klass|
        klass.attributes.merge({
          'studio_name' => studio.name,
          'studio_url' => studio.schedule_url
        })
      }
    else
      { error: "User has not specified a Google calendar." }
    end
  end

  def self.match_classes(user_id, studio_id)
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

  def self.no_conflict(klass, user, events)
    date_str   = klass.date.to_date.to_s
    start_time = time_to_datetime(klass.start_time, date_str)
    end_time   = time_to_datetime(klass.end_time, date_str)

    # Compare with user weekly availibility
    JSON.parse(user.availability).each do |weekday|
      if weekday['day'] == klass.date.wday
        conflict = time_to_24hrs(klass.start_time) < weekday['end_time'] ||
                   time_to_24hrs(klass.end_time) > weekday['start_time']
        return false if conflict
      end
    end

    events.each_with_index do |event, i|
      if ( klass.date.to_date == event[:start_time].to_date ||
           klass.date.to_date == event[:end_time].to_date ) &&
         i < events.length
        return false if start_time < event[:end_time] ||
                        end_time > events[i+1][:start_time]
      end
    end

    true
  end

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
