Rails.application.routes.draw do

  root 'sessions#new'
  get 'welcome' => 'sessions#welcome'
  get '/login'  => 'sessions#find_or_create_session'
  get '/logout' => 'sessions#destroy'
  get "/auth/:provider/callback" => "sessions#create"

  get '/schedule' => 'users#schedule'
  get '/customize' => 'users#customize'

  resources :users, only: [:show, :update] do
    get '/studios' => 'users#studios'
    get '/filters' => 'users#filters'
    get '/classes' => 'users#classes'
  end

  resources :calendars, only: [:index, :update]
  get '/calendars/events' => 'calendars#show'

  resources :studios, only: [:index, :show, :create]

  get '/classes' => 'klasses#index'

  resources :filters, only: [:index, :create]
  get '/filters/show' => 'filters#show'

  resources :appointments, only: [:index, :create]
end
