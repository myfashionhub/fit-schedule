class CalendarsController < ApplicationController

  before_filter :initialize_model

  def index
    begin
      calendars = Rails.cache.fetch(
        "calendars/#{current_user.id}", expires_in: 2.hours
      ) do
        @calendar.list
      end

      render json: { calendars: calendars }
    rescue => error
      reset_session
      msg = "Your Google session has expired. Please re-authenticate."
      render json: { error: msg }
    end    
  end

  def update
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
