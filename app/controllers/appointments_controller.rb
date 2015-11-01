class AppointmentsController < ApplicationController

  def index
    classes = Appointment.get_classes(current_user.id)
    render json: { classes: classes }
  end

  def create
    Appointment.update_or_create(params)
    classes = Appointment.get_classes(user_id)
    render json: { classes: classes }
  end

end
