class UsersController < ApplicationController

  before_filter :authorize

  def show
    user = User.find(params[:id])
    render json: { user: user }
  end

  def update
    current_user.update(calendar_id: params[:calendar_id]) if current_user
    attribute = 'calendar'
    render json: { msg: "Successfully updated #{attribute}" }
  end

  def schedule
  end

  def customize
  end

  def studios
    result = []

    filters = Filter.where(user_id: current_user.id)
    studio_ids = filters.pluck(:studio_id).uniq

    studio_ids.each do |studio_id|
      object = {}
      object[:studio] = Studio.find(studio_id)
      object[:filters] = filters.where(studio_id: studio_id)
      result.push(object)
    end

    render json: { studios: result }
  end

  def filters
    # All filters for one studio
    filters = Filter.where(
      user_id: params[:user_id].to_i,
      studio_id: params[:studio_id].to_i
    )

    render json: { filters: filters }
  end

  def classes
    # suggested classes for all user's studios
    calendar = Calendar.new(current_user.google_token)
    events = calendar.list_events(current_user.calendar_id)

    error_code = events.is_a?(Hash) ? events[:code] : nil

    if error_code.present? && error_code === 401
      current_user.refresh_google_token
      new_expiry = Time.at(current_user.token_expires).to_datetime

      if !(new_expiry > Time.now)
        session[:user_id] = nil
        session[:google_token] = nil
        msg = "Your Google session has expired. Please re-authenticate."
        render json: { error: msg }
        return
      else
        session[:google_token] = current_user.google_token
        events = calendar.list_events(current_user.calendar_id)
      end
    end

    classes = suggest_classes(current_user, events)
    render json: { classes: classes }
  end

  def suggest_classes(user, events)
    Rails.cache.fetch(
      "users/#{current_user.id}/suggested_classes",
      expires_in: 2.hours
    ) do
      studio_ids = user.filters.pluck(:studio_id).uniq
      studio_ids.map do |studio_id|
        Filter.suggest_classes(user, events, studio_id)
      end.flatten
    end
  end
end
