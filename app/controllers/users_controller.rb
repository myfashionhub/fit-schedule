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

end
