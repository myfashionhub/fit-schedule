class StudiosController < ApplicationController

  def show
    studio_id = params[:id]
    studio = Studio.find(studio_id)

    classes = Rails.cache.fetch(
      "studios/#{studio_id}/classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).where('date >= ?', Date.today)
    end

    unique_classes = Rails.cache.fetch(
      "studios/#{studio_id}/unique_classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).pluck(:name).uniq
    end

    render json: {
             studio: studio, classes: classes,
             unique_classes: unique_classes
           }
  end

  def create
    new_studio = false
    provider = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}"

    studio = Studio.find_by(schedule_url: params[:url].strip)
    scraper = scraper_class.constantize.new(params[:url], studio)

    if !studio
      new_studio = true
      studio = scraper.parse_studio
    end

    if new_studio || studio.updated_at.nil? ||
       studio.updated_at < Time.now - 21600
      scraper.parse_classes
      studio.update(updated_at: Time.now)
      invalidate_studio_cache(studio.id)
    end

    render json: { studio: studio }
  end

  def invalidate_studio_cache(id)
    keys = [
      "studios/#{id}/classes", "studios/#{id}/unique_classes"
    ]
    keys.each { |key| Rails.cache.delete(key) }
  end

end
