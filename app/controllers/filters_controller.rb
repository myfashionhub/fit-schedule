class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: params[:user_id])
    filters = Filter.where(studio_id: params[:studio_id]) \
      if params[:studio_id].present?

    render json: { filters: filters }
  end

  def create
    user = User.find(params[:user_id])
    # Create new and/or delete class filters
    Filter.update_user_preferences(params, user)
    Rails.cache.delete("users/#{current_user.id}/suggested_classes")

    filters = user.filters.where(studio_id: params[:studio_id])
    render json: { filters: filters }
  end

  def destroy
    user = User.find(params[:user_id])
    studio = Studio.find(params[:studio_id])
    user.filters.where(studio_id: params[:studio_id]).each { |f| f.delete }
    Rails.cache.delete("users/#{current_user.id}/suggested_classes")

    render json: { msg: "Successfully removed #{studio.name} from your favorites" }
  end

end
