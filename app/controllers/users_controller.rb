class UsersController < ApplicationController
  before_action :authorize

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
      begin
        object[:studio] = Studio.find(studio_id)
        object[:filters] = filters.where(studio_id: studio_id)
      rescue
        next
      end
      result.push(object) if !object.blank?
    end

    render json: { studios: result }
  end

  def classes
    events = current_user.events

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
        events = current_user.events
      end
    end

    classes = suggest_classes(current_user, events, params[:studio_id])
    render json: { classes: classes }
  end

  def suggest_classes(user, events, studio_id)
    if studio_id.present?
      Rails.cache.fetch(
        "users/#{current_user.id}/suggested_classes/#{studio_id}",
        expires_in: 2.hours
      ) do
        Filter.suggest_classes(user, events, studio_id)
      end
    else
      Rails.cache.fetch(
        "users/#{current_user.id}/suggested_classes",
        expires_in: 2.hours
      ) do
        Filter.suggest_classes(user, events)
      end
    end
  end
end
