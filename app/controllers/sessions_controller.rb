class SessionsController < ApplicationController

  def new
    render 'sessions/new'
  end

  def create
    user = User.find_or_create(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to '/schedule'
  end

end
