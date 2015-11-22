Rails.application.routes.draw do

  root 'sessions#new'
  get 'welcome' => 'sessions#welcome'
  get "/auth/:provider/callback" => "sessions#create"
  get '/logout' => 'sessions#destroy'

  put '/users' => 'users#update'
  get '/schedule' => 'users#schedule'
  get '/customize' => 'users#customize'
  get '/users/studios' => 'users#studios'

  resources :calendars, only: [:index, :update]
  get '/calendars/events' => 'calendars#show'

  resources :studios, only: [:show]

  get '/classes' => 'klasses#index'
  post '/classes' => 'klasses#create'

  resources :filters, only: [:index]
  get '/filters/show' => 'filters#show'
  get '/filters/apply' => 'filters#apply'
  post '/filters' => 'filters#update'

  resources :appointments, only: [:index, :update, :destroy]
end
