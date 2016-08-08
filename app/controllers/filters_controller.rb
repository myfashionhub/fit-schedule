class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: user.id)
    filters = Filter.where(studio_id: params[:studio_id]) \
      if params[:studio_id].present?

    render json: { filters: filters }
  end

  def create
    Filter.update_user_preferences(params, user)
    filters = Filter.where(
      user_id: user.id,
      studio_id: params[:studio_id]
    )

    render json: { filters: filters }
  end

  def user
    User.find(params[:user_id])
  end

end
