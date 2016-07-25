Rails.application.routes.draw do

  root 'sessions#new'
  get 'welcome' => 'sessions#welcome'
  get "/auth/:provider/callback" => "sessions#create"
  get '/logout' => 'sessions#destroy'

  get '/schedule' => 'users#schedule'
  get '/customize' => 'users#customize'

  resources :users, only: [:show, :update] do
    get '/studios' => 'users#studios'
    get '/filters' => 'users#filters'
  end

  resources :calendars, only: [:index, :update]
  get '/calendars/events' => 'calendars#show'

  resources :studios, only: [:index, :show, :create]

  get '/classes' => 'klasses#index'

  resources :filters, only: [:index, :create]
  get '/filters/show' => 'filters#show'
  get '/filters/apply' => 'filters#apply'

  resources :appointments, only: [:index, :create]
end
