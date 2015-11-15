class FiltersController < ApplicationController

  def index
    filters = Filter.where(user_id: current_user.id) if current_user
    render json: { filters: filters }
  end

  def update
    Filter.update_user_preferences(params, current_user)
    filters = Filter.where(user_id: current_user.id, studio_id: params[:studio_id])

    render json: { filters: filters }
  end

  def show
    # suggested classes for one studio
    classes = Filter.suggest_classes(current_user, params[:studio_id])
    render json: { classes: classes }
  end

  def apply
    # suggested classes for all user's studios
    studio_ids = current_user.klasses.pluck(:studio_id).uniq

    classes = studio_ids.map do |studio_id|
      Filter.suggest_classes(current_user, studio_id)
    end.flatten

    error = classes.first.has_key?(:error) rescue nil
    if error
      session[:user_id] = nil
      msg = "Your Google session has expired. Please re-authenticate."
      render json: { error: msg }
    else
      render json: { classes: classes }
    end
  end

end
