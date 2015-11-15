require 'clockwork'

handler do |job|
  
end

every(6.hours, 'update_schedules') do 
  execute_rake('worker.rake','worker:update_schedules')
end


def execute_rake(filename, task)
  Rake.application = Rake::Application.new
  load "#{Rails.root}/lib/tasks/#{filename}"
  rake[task].invoke
end

