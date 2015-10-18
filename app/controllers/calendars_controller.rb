class CalendarsController < ApplicationController

  before_filter :initialize_model

  def index
    begin
      calendars = @calendar.list
      render json: { calendars: calendars }
    rescue => error
      reset_session
      msg = "Your Google session has expired. Please re-authenticate."
      render json: { error: msg }
    end
  end
    
  def show
  end

  def update
  end

  private; def initialize_model
    @calendar = Calendar.new(current_user.google_token) if current_user
  end

end
