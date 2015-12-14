class KlassesController < ApplicationController

  def index
  end

  def new
  end

  def create
    provider = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}"
    classes = nil
    result = nil
    new_studio = false

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

    classes = studio.all_classes
    render json: { studio: studio, classes: classes }
  end

  
end
