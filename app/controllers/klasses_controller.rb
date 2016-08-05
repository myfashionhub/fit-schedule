class KlassesController < ApplicationController

  def index
    studio = Studio.find(params[:studio_id]) if params[:studio_id]
    classes = studio.present? ? studio.all_classes : []
    render json: { classes: classes }
  end
  
end
