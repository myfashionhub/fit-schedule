class StudiosController < ApplicationController

  def show
    studio_id = params[:id]
    studio = Studio.find(studio_id)

    classes = Rails.cache.fetch("#{studio_id}/classes", expires_in: 2.hours) do
      Klass.where(studio_id: studio_id).where('date >= ?', Date.today)
    end

    unique_classes = Rails.cache.fetch(
      "#{studio_id}/unique_classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).pluck(:name).uniq
    end

    render json: { studio: studio, classes: classes,
                   unique_classes: unique_classes
                 }
  end

end
