class Appointment < ActiveRecord::Base

  belongs_to :user
  belongs_to :klass, inverse_of: :appointments

  validates_uniqueness_of :klass_id, scope: :user_id


  def self.update_or_create(params, user_id)
    params[:class_ids].each do |class_id|
      existing_appt = Appointment.find_by(user_id: user_id, klass_id: class_id)

      if !existing_appt
        Appointment.create(user_id: user_id, klass_id: class_id)
      end
    end

    # Remove deleted appts
    future_appts = Appointment.where(user_id: user_id).select do |appt|
      klass = Klass.find(appt.klass_id) rescue nil
      klass.present? ? klass.date >= Date.today : nil
    end.compact!

    return if !future_appts.is_a?(Array) || future_appts.size == 0

    future_appts.each do |appointment|
      if params[:class_ids].index(appointment.klass_id.to_s).blank?
        appointment.destroy
      end
    end
  end

end
