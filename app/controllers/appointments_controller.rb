class AppointmentsController < ApplicationController

  def index
    classes = User.find(current_user.id).klasses.where('date >= ?', Date.today)

    classes.to_a.map! do |klass|
      studio = Studio.find(klass.studio_id)
      klass.attributes.merge({
        studio_name: studio.name,
        studio_url: studio.schedule_url
      })
    end

    render json: { classes: classes }
  end

  def create
    Appointment.update_or_create(params, current_user.id)
    render json: { msg: 'Successfully updated your class schedule.' }
  end

end
