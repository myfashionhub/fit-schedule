class Studio < ActiveRecord::Base
  has_many :klasses

  validates :schedule_url, presence: true

  def all_classes
    Klass.where(studio_id: self.id)
  end

end
