class UsersController < ApplicationController

  def show
  end

  def update
    current_user.update(calendar_id: params[:calendar_id]) if current_user
  end

end
