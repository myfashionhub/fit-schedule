class KlassesController < ApplicationController

  def index
  end

  def new
  end

  def create
    provider = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{provider}"
    classes = nil

    studio = Studio.find_by(schedule_url: params[:url])
    result = scraper_class.constantize.get_classes(params[:url])

    studio = result[:studio] if !studio
    classes = Klass.create_from_raw(result) if studio.id.present?
    # Check if classes have been polled recently

    render json: { studio: studio, classes: classes }
  end

  
end
