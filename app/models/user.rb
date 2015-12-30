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
        refresh_token: auth_hash['credentials']['refresh_token'],
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

end
