class Klass < ActiveRecord::Base
  self.table_name = 'classes'

  belongs_to :studio
  has_many   :appointments
  has_many   :users, through: :appointments

  validates  :name,       presence: true
  validates  :date,       presence: true
  validates  :start_time, presence: true
  validates  :studio_id,  presence: true

  validates_uniqueness_of :name, scope: [:studio_id, :date, :start_time]
  
  def self.create_from_raw(klass)
    Klass.find_or_create_by({
      name:       klass[:name],
      date:       klass[:date],
      start_time: klass[:start_time],
      end_time:   klass[:end_time],
      instructor: klass[:instructor],
      duration:   klass[:duration],
      studio_id:  klass[:studio_id]
    })
  end

end
