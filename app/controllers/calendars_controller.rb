class CalendarsController < ApplicationController
  before_action :initialize_model

  def index
    begin
      calendars = @calendar.list
      render json: { calendars: calendars }
    rescue => error # TODO: More specific error
      reset_session
      Rails.logger.error(error)

      msg = "Your Google session has expired. Please re-authenticate."
      render json: { error: msg }
    end    
  end

  def update
    # TODO: Add appointment to Google cal
  end

  def show # for testing only
    id = params[:id] || current_user.calendar_id
    events = @calendar.list_events(id)

    render json: { events: events }
  end

  private; def initialize_model
    @calendar = Calendar.new(current_user.google_token)
  end

end
