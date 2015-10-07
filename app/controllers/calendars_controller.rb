class CalendarsController < ApplicationController

  before_filter :initialize_model

  def index
    calendars = @calendar.list
    render json: { calendars: calendars }
  end
    
  def show
  end

  def update
  end

  private; def initialize_model
    @calendar = Calendar.new(current_user.google_token)
  end

end
