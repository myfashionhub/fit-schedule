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

  def self.find_or_create(url)
    studio = nil
    provider = url.split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}".constantize rescue nil

    if scraper_class.present?
      scraper = scraper_class.new(url)
      studio = scraper.parse_studio
    end
    studio
  end

  def self.match(term)
    studios_by_name = Studio.where('name iLIKE ?', "%#{term}%").to_a
    if studios_by_name.size > 10
      if studios_by_name.size < 50
        return studios_by_name
      else
        return studios_by_name[0..49]
      end
    end

    studios_by_url = Studio.all.select do |studio|
      studio.schedule_url.gsub('https://www.fitreserve.com/', '').include?(term.gsub(' ', ''))
    end

    (studios_by_name || []).concat(studios_by_url || []).uniq
  end
end
