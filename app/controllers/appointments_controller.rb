class AppointmentsController < ApplicationController

  def index
    classes = User.find(current_user.id).klasses.where('date >= ?', Date.today)
    render json: { classes: classes }
  end

  def update
    user_id = current_user.id
    Appointment.update_or_create(params, user_id)
    classes = User.find(user_id).klasses
    render json: { classes: classes }
  end

  def destroy
    Appointment.destroy(params[:id])
    classes = User.find(current_user.id).klasses

    render json: { classes: classes }
  end

end
