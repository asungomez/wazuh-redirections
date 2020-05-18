Rails.application.routes.draw do
  
  resources :branches do
    put 'refresh', to: 'branches#refresh', on: :member
  end
  
  root 'branches#index'
end
