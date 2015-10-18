Rails.application.routes.draw do

  root 'sessions#new'
  get "/auth/:provider/callback" => "sessions#create"
  delete '/sessions' => 'sessions#destroy', as: 'delete_session'

  put '/users' => 'users#update'
  get '/schedule' => 'users#show'

  resources :calendars, only: [:index, :update]
  get '/calendars/events' => 'calendars#show'

  get '/classes' => 'klasses#index'
  post '/classes' => 'klasses#create'

  resources :filters, only: [:index]
  get '/filters/apply' => 'filters#apply'
  post '/filters' => 'filters#update'

end
