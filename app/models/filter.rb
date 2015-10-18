class Filter < ActiveRecord::Base
  belongs_to :user
  belongs_to :studio

  validates_uniqueness_of :class_name, scope: [:studio_id, :user_id]
  
  def self.create_from_raw(filter_obj)
    Filter.find_or_create_by({
      user_id:    filter_obj.user_id,
      studio_id:  filter_obj.studio_id,
      class_name: filter_obj.class_name
    })
  end

  def self.update_user_preferences(filter_objects, user)

    #Filter.create_from_raw(object)
  end
end
