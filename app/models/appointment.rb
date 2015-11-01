class Appointment < ActiveRecord::Base

  belongs_to :user
  belongs_to :klass

  validates_uniqueness_of :klass_id, scope: :user_id

  def update_or_create(params, user_id)
    appointments = Appointment.where(user_id: user_id)
    
    appointments = params[:class_ids].map do |class_id|
      existing = appointments.where(class_id: class_id).first

      if existing
        existing
      else
        new_appt = Appointment.create(
          user_id: user.id,
          klass_id: class_id
          #reminder: user default calendar reminder
        )
      end
    end

    appointments
  end

end
