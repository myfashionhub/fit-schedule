class KlassesController < ApplicationController

  def index
    studio = Studio.find(params[:studio_id]) if params[:studio_id]
    render json: { classes: studio.all_classes }
  end
  
end
