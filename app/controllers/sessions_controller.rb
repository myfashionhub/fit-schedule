class SessionsController < ApplicationController

  def new
    if session[:user_id]
      redirect_to '/schedule'
    else
      redirect_to '/welcome'
    end
  end

  def welcome
    render 'sessions/new'
  end

  def create
    user = User.find_or_create(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to '/schedule'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end

end
