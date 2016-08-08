class User < ActiveRecord::Base

  has_many :filters
  has_many :appointments
  has_many :klasses, through: :appointments

  validates_uniqueness_of :email
  validates :google_uid, presence: true

  def self.find_or_create(auth_hash)
    user = User.find_by(google_uid: auth_hash['uid'])

    if !user
      user = User.create(
        name: auth_hash['info']['name'],
        email: auth_hash['info']['email'],
        image: auth_hash['info']['image'],
        google_uid: auth_hash['uid'],
        availability: self.default_availability,
        google_token: auth_hash['credentials']['token'],
        refresh_token: auth_hash['credentials']['refresh_token'],
        token_expires: auth_hash['credentials']['expires_at']
      )
    else
      user.update(
        google_token: auth_hash['credentials']['token'],
        token_expires: auth_hash['credentials']['expires_at']
      )
    end

    user
  end

  def self.default_availability
    # ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    busy = (1..5).map do |i|
      { day: i, start_time: '9:30', end_time: '18:00' }
    end.to_json
  end

  def refresh_google_token
    uri = URI.parse('https://www.googleapis.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new("/oauth2/v4/token")
    request.body = "client_id=#{ENV['FS_GOOGLE_ID']}&" +
                   "client_secret=#{ENV['FS_GOOGLE_SECRET']}&" +
                   "grant_type=refresh_token&" +
                   "refresh_token=#{self.refresh_token}"
    request.add_field('Content-Type', 'application/x-www-form-urlencoded')
    response = http.request(request)

    if response.code == '200'
      result = JSON.parse(response.body)
      self.update(
        google_token: result['access_token'],
        token_expires: Time.now + result['expires_in']
      )
    end
  end

end
