class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :not_signed_in

  def current_user
    User.find(session[:user_id]) if session[:user_id] \
      rescue session[:user_id] = nil
  end

  def authorize
    if !current_user || !session[:user_id]
      redirect_to root_path
    end
  end

end
