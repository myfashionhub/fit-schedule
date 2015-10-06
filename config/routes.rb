Rails.application.routes.draw do

  root 'sessions#new'
  get "/auth/:provider/callback" => "sessions#create"

  get '/schedule' => 'users#show'
end
