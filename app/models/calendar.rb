class Calendar

  def initialize(token)
    @client = Google::APIClient.new
    @client.authorization.access_token = token
    @service = @client.discovered_api('calendar', 'v3')  
  end
  
  def list
    calendars = []
    result = @client.execute(
      :api_method => @service.calendar_list.list,
      :parameters => {},
      :headers => {'Content-Type' => 'application/json'}
    )

    result = JSON.parse(result.response.body)

    result['items'].each do |item|
      if item['primary']
        calendars.unshift(item)  
      else
        calendars.push(item)
      end
    end

    calendars
  end

  def add(params)
    result = @client.execute(
      :api_method => @service.events.insert,
      :parameters => {
        calendarId: params[:id],
        event: {
          kind: 'calendar#event',
          summary: params[:summary],
          location: params[:location], # studio location
          start: { dateTime: params[:start] },
          end: { dateTime: params[:end] },
          recurrence: []
        }
      },
      :headers => {'Content-Type' => 'application/json'}
    )
  end

  # even reference https://developers.google.com/google-apps/calendar/v3/reference/events/insert

  def update
    result = @client.execute(
      :api_method => @service.events.update,
      :parameters => {
        calendarId: params[:id],
        event: {
          kind: 'calendar#event',
          summary: params[:summary],
          location: params[:location], # studio location
          start: { dateTime: params[:start] },
          end: { dateTime: params[:end] },
          recurrence: []
        }
      },
      :headers => {'Content-Type' => 'application/json'}
    )
  end

  def remove(params)
  end

end
