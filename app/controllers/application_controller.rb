class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :not_signed_in

  def current_user
    session[:user_id].present? ? User.find(session[:user_id]) : nil
  end

  def authorize
    redirect_to root_path if !current_user
  end

end
