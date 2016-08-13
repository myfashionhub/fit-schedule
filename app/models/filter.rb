class Filter < ActiveRecord::Base
  belongs_to :user,   inverse_of: :filters
  belongs_to :studio

  validates      :studio_id, presence: true
  validates      :user_id, presence: true
  validates_uniqueness_of :class_name, scope: [:studio_id, :user_id]


  def self.update_user_preferences(params, user)
    class_names = JSON.parse(params[:class_names])
    user_filters = Filter.where(
                     user_id: user.id,
                     studio_id: params[:studio_id]
                   )

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

  def self.suggest_classes(user, events, studio_id=nil)
    if user.calendar_id.present?
      if studio_id.present?
        classes = self.match_classes(user, studio_id, events)
      else
        studio_ids = user.filters.pluck(:studio_id).uniq
        classes = studio_ids.map do |studio_id|
          self.match_classes(user, studio_id, events)
        end.flatten
      end
    else
      { error: "User has not specified a Google calendar." }
    end
  end


  # Helper
  def self.match_classes(user, studio_id, events)
    studio = Studio.find(studio_id)
    class_names = Filter.where(
                    user_id: user.id, studio_id: studio_id
                  ).pluck(:class_name).uniq

    classes = []
    studio.klasses.each do |klass|
      class_names.each do |name|
        if klass.name == name && klass.date >= Time.now
          classes.push(klass)
        end
      end
    end

    classes.select! { |klass| no_conflict(klass, user, events) }
    classes.map do |klass|
      klass.attributes.merge( {
        'studio_name' => studio.name,
        'studio_url' => studio.schedule_url
      } )
    end
  end

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
                        (events[i+1].present? &&
                         end_time > events[i+1][:start_time])
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
