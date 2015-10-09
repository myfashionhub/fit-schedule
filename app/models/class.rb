class Class < ActiveRecord::Base
  belongs_to :studio
  has_many   :appointments

  
end
