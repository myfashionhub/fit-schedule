class UsersController < ApplicationController
  before_filter :authorize

  def update
    current_user.update(calendar_id: params[:calendar_id]) if current_user
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

end
