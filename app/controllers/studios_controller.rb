class StudiosController < ApplicationController

  def show
    studio_id = params[:id]
    studio = Studio.find(studio_id)

    classes = Rails.cache.fetch("#{studio_id}/classes", expires_in: 2.hours) do
      Klass.where(studio_id: studio_id).where('date >= ?', Date.today)
    end

    unique_classes = Rails.cache.fetch(
      "#{studio_id}/unique_classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).pluck(:name).uniq
    end

    render json: { studio: studio, classes: classes,
                   unique_classes: unique_classes
                 }
  end

  def create
    new_studio = false
    provider = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}"

    studio = Studio.find_by(schedule_url: params[:url].strip)

    if !studio
      result = scraper_class.constantize.get_classes(params[:url])
      studio = result[:studio]
      new_studio = true
    end

    if new_studio || studio.updated_at.nil? ||
       studio.updated_at < Time.now - 21600
      scraper_class.constantize.get_classes(params[:url]) if result.nil?
      studio.update(updated_at: Time.now)
    end

    render json: { studio: studio }
  end

end
