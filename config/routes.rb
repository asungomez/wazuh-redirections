Rails.application.routes.draw do
  resources :branches
  
  root 'branches#index'
end
