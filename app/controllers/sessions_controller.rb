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

  def find_or_create_session
    if session[:google_token].present?
      user = User.find_by(google_token: session[:google_token])
      session[:user_id] = user.id if user
      redirect_to '/schedule'
    else
      redirect_to '/auth/google_oauth2'
    end
  end

  def create
    user = User.find_or_create(request.env["omniauth.auth"])
    session[:user_id] = user.id
    session[:google_token] = user.google_token
    redirect_to '/schedule'
  end

  def destroy
    session[:user_id] = nil
    redirect_to '/welcome'
  end

end
