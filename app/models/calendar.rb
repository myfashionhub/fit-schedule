class Calendar

  def initialize(token)
    @client = Google::APIClient.new
    @client.authorization.access_token = token
    @service = @client.discovered_api('calendar', 'v3')
  end
  
  def list
    result = @client.execute(
      :api_method => @service.calendar_list.list,
      :parameters => {},
      :headers => {'Content-Type' => 'application/json'}
    )
    calendars = []
    result['items'].each do |item|
      name = item['id']
      reminder = item['defaultReminders'].first['minutes']
      if item['primary']
        calendars.unshift(name: name, reminder: reminder)  
      else
        calendars.push(name: name, reminder: reminder)
      end
    end

    calendars
  end

  def add(params)
  end

  def remove(params)
  end

end
