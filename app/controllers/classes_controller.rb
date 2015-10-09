class ClassesController < ApplicationController

  def index
  end

  def new
  end

  def create
    puts params
    studio_name = params[:url].split('.')[1].downcase.capitalize
    scraper_class = "Scraper::#{studio_name}"
    result = scraper_class.constantize.get_classes(params[:url])
    render json: { classes: result }
  end

  
end
