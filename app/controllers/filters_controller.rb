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

  def apply
    # suggested classes for all user's studios
    cache_key = "users/#{current_user.id}/suggested_classes"
    calendar = Calendar.new(current_user.google_token)
    events = calendar.list_events(current_user.calendar_id)

    error_code = events.is_a?(Hash) ? events[:code] : nil
    if error_code.present? && error_code === 401
      session[:user_id] = nil
      session[:google_token] = nil
      msg = "Your Google session has expired. Please re-authenticate."
      render json: { error: msg }
    else
      classes = Rails.cache.fetch(
        cache_key, expires_in: 2.hours
      ) do
        studio_ids = current_user.filters.pluck(:studio_id).uniq
        studio_ids.map do |studio_id|
          Filter.suggest_classes(current_user, events, studio_id)
        end.flatten
      end
      render json: { classes: classes }
    end
  end

end
