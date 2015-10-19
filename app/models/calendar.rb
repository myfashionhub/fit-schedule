class Calendar

  def initialize(token)
    @client = Google::APIClient.new(
      application_name: 'calendar',
      application_version: 'v3'
    )
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
    params = {
      calendarId: params[:id],
      event: {
        kind: 'calendar#event',
        summary: params[:summary],
        location: params[:location], # studio location
        start: { dateTime: params[:start] },
        end: { dateTime: params[:end] },
        recurrence: []
      }
    }

    result = @client.execute(
      :api_method => @service.events.update,
      :parameters => params,
      :headers => {'Content-Type' => 'application/json'}
    )
  end

  def remove(params)
  end

  def list_events(id)
    params = {
      calendarId: id,
      timeMin:    Date.today.rfc3339,
      singleEvents: true,
      orderBy:   'startTime'
    }

    result = @client.execute(
      :api_method => @service.events.list,
      :parameters => params,
      :headers => {'Content-Type' => 'application/json'}
    )

    events = JSON.parse(result.response.body)['items']

    events.map do |event|
      if event['kind'] == 'calendar#event' && event['status'] == 'confirmed'
        {
          name: event['summary'],
          start_time: Time.parse(event['start']['dateTime']),
          end_time: Time.parse(event['end']['dateTime']),
          link: event['htmlLink']
        }
      end
    end
  end

end
