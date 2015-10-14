Rails.application.routes.draw do

  root 'sessions#new'
  get "/auth/:provider/callback" => "sessions#create"

  get '/schedule' => 'users#show'
  resources :calendars, only: [:index, :show, :update]

  get '/classes' => 'klasses#index'
  post '/classes' => 'klasses#create'

end
