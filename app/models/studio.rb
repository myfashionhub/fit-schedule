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
    studio = Studio.where('name iLIKE ?', "%#{term}%").first
    return studio if studio.present?

    Studio.all.each do |studio|
      if studio.name.downcase.include?(term) ||
         studio.schedule_url.include?(term.gsub(' ', ''))
        return studio
      end
    end
    nil
  end
end
