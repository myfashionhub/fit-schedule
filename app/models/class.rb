class Class < ActiveRecord::Base
  belongs_to :studio
  has_many   :appointments
  
  def self.create_from_raw(data)
    data[:classes].map do |klass|
      Class.find_or_create_by({
        name:       klass["name"],
        date:       klass["date"],
        start_time: klass["start_time"],
        end_time:   klass["end_time"],
        instructor: klass['instructor'],
        duration:   klass["duration"],
        studio_id:  data[:studio].id
      })
    end
  end

end
