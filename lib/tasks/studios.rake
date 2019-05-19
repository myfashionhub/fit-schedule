namespace :studios do
  task clean_data: :environment do |task|
    studio_ids = Filter.all.pluck(:studio_id).uniq
    studio_ids.each do |studio_id|
      begin
        Studio.find(studio_id)
      rescue => e
        puts "Removing filters for studio #{studio_id}"
        Filter.where(studio_id: studio_id).delete_all
      end
    end
  end
end
