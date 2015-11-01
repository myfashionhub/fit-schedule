class Appointment < ActiveRecord::Base

  def update_or_create(params)
    user = User.find(params[:user_id])
    appointments = Appointment.where(user_id: user.id)
    
    appointments = params[:class_ids].map do |class_id|
      existing = appointments.where(class_id: class_id).first

      if existing
        existing
      else
        new_appt = Appointment.create(
          user_id: user.id,
          class_id: class_id
        )
      end
    end

    appointments
  end

  def get_classes(user_id)
    appointments = Appointment.where(user_id: user_id)
    classes = appointments.map do |a|
      Class.find(a.class_id) rescue nil
    end

    classes.compact
  end

end
