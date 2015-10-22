class UsersController < ApplicationController

  def update
    current_user.update(calendar_id: params[:calendar_id]) if current_user
  end

  def schedule
  end

  def customize
  end

end
