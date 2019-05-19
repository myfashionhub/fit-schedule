require 'google/apis/calendar_v3'

class Calendar
  def initialize(token)
    authorization = Signet::OAuth2::Client.new(access_token: token)
    Google::Apis::RequestOptions.default.authorization = authorization
    @service = Google::Apis::CalendarV3::CalendarService.new
  end
  
  def list
    calendars = []
    items = nil

    @service.list_calendar_lists do |result, err|
      items = result.items
    end
    items.each do |item|
      if item.primary
        calendars.unshift(item)
      else
        calendars.push(item)
      end
    end

    calendars
  end

  def add(params)
    result = @service.insert_event(
      calendarId: params[:id],
      event: {
        kind: 'calendar#event',
        summary: params[:summary],
        location: params[:location], # studio location
        start: { dateTime: params[:start] },
        end: { dateTime: params[:end] },
        recurrence: []
      }
    )
  end

  def update
    params = {
      calendarId: params[:id],
      event: {
        kind: 'calendar#event',
        summary: params[:summary],
        location: params[:location], # studio location
        start: {dateTime: params[:start]},
        end: {dateTime: params[:end]},
        recurrence: []
      }
    }
    puts "UPDAT EVENTS"
    result = @client.execute(
      :api_method => @service.events.update,
      :parameters => params,
      :headers => {'Content-Type' => 'application/json'}
    )
  end

  def remove(params)
  end

  def list_events(calendar_id)
    items = nil
    @service.list_events(
      calendar_id,
      single_events: true,
      order_by: 'startTime',
      time_min: Date.today.rfc3339
    ) do |result, err|
      items = result.items
    end

    items.map do |event|
      start_time = parse_time(event.start)
      end_time   = parse_time(event.end)

      if event.kind == 'calendar#event' &&
         event.status == 'confirmed' &&
         start_time >= Time.now &&
         start_time <= Time.now + 1814400
         # Events maximum 3 weeks in the future
        {
          name: event.summary,
          start_time: start_time,
          end_time: end_time,
          link: event.html_link,
        }
      end
    end.compact
  end

  def parse_time(event)
    timestamp = event.date_time || event.date
    Time.parse(timestamp.to_s)
  end

end
