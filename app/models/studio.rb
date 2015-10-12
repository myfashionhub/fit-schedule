class Studio < ActiveRecord::Base
  has_many :classes

  validates :schedule_url, presence: true

  def all_classes
    Class.where(studio_id: self.id)
  end

end
