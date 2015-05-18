Rails.application.routes.draw do
  resources :people
  root to: 'visitors#index'
end
