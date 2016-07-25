class Studio < ActiveRecord::Base
  has_many :klasses

  validates :schedule_url, presence: true,
                           uniqueness: true
  validates :name,         presence: true,
                           uniqueness: true

  def all_classes
    Klass.where(studio_id: self.id).where('date >= ?', Date.today)
  end

  def past_classes
    Klass.where(studio_id: self.id).where('date < ?', Date.today)
  end

end
