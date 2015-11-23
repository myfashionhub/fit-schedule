class AppointmentsController < ApplicationController

  def index
    classes = User.find(current_user.id).klasses.where('date >= ?', Date.today)
    render json: { classes: classes }
  end

  def create
    Appointment.update_or_create(params, current_user.id)
    render json: { msg: 'Successfully updated your class schedule.' }
  end

end
