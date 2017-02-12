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

  def self.match(term)
    studios_by_name = Studio.where('name iLIKE ?', "%#{term}%").to_a
    return studios_by_name if studios_by_name.size > 10

    studios_by_url = Studio.all.select do |studio|
      studio.schedule_url.include?(term.gsub(' ', ''))
    end

    (studios_by_name || []).concat(studios_by_url || []).uniq
  end
end
