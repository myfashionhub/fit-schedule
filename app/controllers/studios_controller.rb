class StudiosController < ApplicationController

  def show
    studio_id = params[:id]
    studio = Studio.find(studio_id)

    classes = Rails.cache.fetch(
      "studios/#{studio_id}/classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).where('date >= ?', Date.today)
    end

    unique_classes = Rails.cache.fetch(
      "studios/#{studio_id}/unique_classes", expires_in: 2.hours
    ) do
      Klass.where(studio_id: studio_id).pluck(:name).uniq
    end

    render json: {
             studio: studio, classes: classes,
             unique_classes: unique_classes
           }
  end

  def create
    provider = nil; scraper_class = nil
    url = params[:url]

    if url.present?
      provider = url.split('.')[1].downcase.capitalize
      scraper_class = "Scraper::#{provider}"
    end

    if studio.blank? && scraper_class.blank?
      render json: { msg: "Cannot find studio with the name #{params[:term]}" }
      return
    end

    scraper = scraper_class.constantize.new(url, studio)
    studio = scraper.parse_studio

    render json: { studio: studio }
  end

  def search
    if params[:url].present?
      url = params[:url].strip
      result = [Studio.find_by(schedule_url: url)]
    elsif params[:term].present?
      result = Studio.match(params[:term])
    end

    render json: result
  end

end
