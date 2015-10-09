Rails.application.routes.draw do

  root 'sessions#new'
  get "/auth/:provider/callback" => "sessions#create"

  get '/schedule' => 'users#show'
  resources :calendars, only: [:index, :show, :update]
  resources :classes, only: [:index, :new, :create]

end
