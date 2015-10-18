class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: current_user.id) if current_user
    render json: { filters: filters }
  end

  def update
    Filter.update_user_preferences(params[:filters], current_user)
  end

  def apply
    classes = Filter.suggest_classes(current_user, params[:studio_id])
    render json: { classes: classes }
  end

end
