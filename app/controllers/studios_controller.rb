class StudiosController < ApplicationController

  def show
    studio_id = params[:id]
    studio = Studio.find(studio_id)

    if studio.updated_at.nil? || studio.updated_at < Time.now - 21600
      studio.scraper.parse_classes
    end

    classes = Rails.cache.fetch(
      "studios/#{studio_id}/classes", expires_in: 2.hours
    ) do
      studio.all_classes
    end

    unique_classes = Rails.cache.fetch(
      "studios/#{studio_id}/unique_classes", expires_in: 2.hours
    ) do
      studio.class_types
    end

    render json: {
      studio: studio, classes: classes,
      unique_classes: unique_classes
    }
  end

  def search
    if params[:url].present?
      url = params[:url].strip
      result = Studio.find_by(schedule_url: url)
      result = Studio.find_or_create(params[:url]) if result.blank?

      if result.present?
        result = [result]
      else
        render json: { error: "Cannot find or parse studio from #{params[:url]}" }
        return
      end
    elsif params[:term].present?
      result = Studio.match(params[:term])
    end

    render json: result
  end

end
