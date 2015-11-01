class User < ActiveRecord::Base

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
        google_token: auth_hash['credentials']['token']
      )
    else
      user.update(google_token: auth_hash['credentials']['token'])
    end

    user
  end

end
