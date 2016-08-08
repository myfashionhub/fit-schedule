class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: current_user.id) if current_user
    render json: { filters: filters }
  end

  def create
    Filter.update_user_preferences(params, current_user)
    filters = Filter.where(
      user_id: current_user.id,
      studio_id: params[:studio_id]
    )

    render json: { filters: filters }
  end

  def show
    # suggested classes for one studio
    classes = Filter.suggest_classes(current_user, params[:studio_id])
    render json: { classes: classes }
  end

end
