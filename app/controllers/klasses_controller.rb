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

    studio = Studio.find_by(schedule_url: params[:url])
    
    if !studio
      result = scraper_class.constantize.get_classes(params[:url])
      studio = result[:studio]
    end
    
    if studio.updated_at.nil? || studio.updated_at < Time.now - 21600
      result = scraper_class.constantize.get_classes(params[:url]) if result.nil?
      classes = Klass.create_from_raw(result)
    else
      classes = studio.all_classes
      studio.update(updated_at: Time.now)
    end

    render json: { studio: studio, classes: classes }
  end

  
end
