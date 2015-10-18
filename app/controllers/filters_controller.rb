class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: current_user.id) if current_user
    render json: { filters: filters }
  end

  def update_user_preferences
    Filter.update_user(params[:filters], current_user)
  end

end
