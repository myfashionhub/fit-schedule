class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: current_user.id) if current_user
    render json: { filters: filters }
  end

  def update
    Filter.update_user_preferences(params[:filters], current_user)
  end

  def show
    # suggested classes for one studio
    classes = Filter.suggest_classes(current_user, params[:studio_id])
    render json: { classes: classes }
  end

  def apply
    # suggested classes for all user's studios
    studio_ids = Filter.favorite_studios(current_user.id)

    classes = studio_ids.map do |studio_id|
      Filter.suggest_classes(current_user, studio_id)
    end.flatten

    render json: { classes: classes }
  end

end
