class Filter < ActiveRecord::Base
  belongs_to :user
  belongs_to :studio

  validates_uniqueness_of :class_name, scope: [:studio_id, :user_id]
  
  def self.create_from_raw(filter_obj, studio_id, user_id)
    Filter.find_or_create_by({
      user_id:    filter_obj.user_id,
      studio_id:  filter_obj.studio_id,
      class_name: filter_obj.class_name
    })
  end

  def self.update_user_preferences(params, user)
    params[:filters].each do |filter_obj|
      Filter.create_from_raw(filter_obj, studio_id, user.id)
    end
  end

  def self.suggest_classes(user, studio_id)
    if user.calendar_id
      calendar = Calendar.new(user.google_token)
      events = calendar.list_events(user.calendar_id)
      classes = Filter.get_preferences(user.id, studio_id)

      classes.select do |klass|
        date_str   = klass.date.to_date.to_s
        start_time = convert_to_datetime(klass.start_time, date_str)
        end_time   = convert_to_datetime(klass.end_time, date_str)  

        events.each do |event|
          klass if start_time > event[:end_time] && end_time < event[:start_time]
        end
      end
    else
      { error: "The calendar with id #{user.calendar_id.inspect} is not found." }
    end 
  end

  def self.get_preferences(user_id, studio_id)
    class_names = Filter.where(user_id: user_id, studio_id: studio_id).
                    pluck(:class_name).uniq

    classes = []
    Klass.where(studio_id: studio_id).each do |klass|
      class_names.each do |name|
        classes.push(klass) if klass.name == name
      end
    end

    classes
  end

  def self.favorite_studios(user_id)
    User.find(user_id).klasses.pluck(:studio_id).uniq
  end

  def self.convert_to_datetime(time_str, date_str)
    time_str = time_str.include?('AM') ?
                 time_str.split(' ').first :
                 ((time_str.split(' ').first).to_i + 12).to_s

    Time.parse(date_str + ' ' + time_str)
  end

end
