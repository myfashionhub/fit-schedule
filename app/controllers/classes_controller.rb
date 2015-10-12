class ClassesController < ApplicationController

  def index
  end

  def new
  end

  def create
    provider = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}"
    classes = nil

    studio = Studio.find_by(schedule_url: params[:url])
    if studio
      classes = studio.all_classes
    else
      result = scraper_class.constantize.get_classes(params[:url])
      studio = result[:studio]
      #classes = Class.create_from_raw(result) if studio.id.present?
    end
    
    render json: { studio: studio, classes: result[:classes] }
  end

  
end
