class SessionsController < ApplicationController

  def new
    render 'sessions/new'
  end

  def create
    user = User.find_or_create(request.env["omniauth.auth"])
    binding.pry
    client = Google::APIClient.new
    client.authorization.access_token = user.google_token
    service = client.discovered_api('calendar', 'v3')
    
    result = client.execute(
      :api_method => service.calendar_list.list,
      :parameters => {},
      :headers => {'Content-Type' => 'application/json'}
    )
    binding.pry
    puts "RESULT #{result.data}"
  end

end
