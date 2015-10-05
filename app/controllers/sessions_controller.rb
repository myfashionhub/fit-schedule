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

#<Google::APIClient::Schema::Calendar::V3::CalendarList:0x3fe5aca6a140 DATA:{"kind"=>"calendar#calendarList", "etag"=>"\"1443996858681000\"", "nextSyncToken"=>"CKiNxr7rqcgCEhh2Lm5lc3NhLm5ndXllbkBnbWFpbC5jb20=", "items"=>[{"kind"=>"calendar#calendarListEntry", "etag"=>"\"1436415546507000\"", "id"=>"v.nessa.nguyen@gmail.com", "summary"=>"v.nessa.nguyen@gmail.com", "timeZone"=>"America/New_York", "colorId"=>"15", "backgroundColor"=>"#9fc6e7", "foregroundColor"=>"#000000", "selected"=>true, "accessRole"=>"owner", "defaultReminders"=>[{"method"=>"popup", "minutes"=>30}, {"method"=>"email", "minutes"=>10}], "notificationSettings"=>{"notifications"=>[{"type"=>"eventCreation", "method"=>"email"}, {"type"=>"eventChange", "method"=>"email"}, {"type"=>"eventCancellation", "method"=>"email"}, {"type"=>"eventResponse", "method"=>"email"}]}, "primary"=>true}, {"kind"=>"calendar#calendarListEntry", "etag"=>"\"1435851646473000\"", "id"=>"en.usa#holiday@group.v.calendar.google.com", "summary"=>"Holidays in United States", "description"=>"Holidays and Observances in United States", "timeZone"=>"America/New_York", "colorId"=>"19", "backgroundColor"=>"#c2c2c2", "foregroundColor"=>"#000000", "selected"=>true, "accessRole"=>"reader", "defaultReminders"=>[]}]}>
