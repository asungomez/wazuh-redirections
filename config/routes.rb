Rails.application.routes.draw do
  
  resources :branches do
    put 'refresh', to: 'branches#refresh', on: :member
    get 'pages/new', to: 'branches#new_pages', on: :member, as: :new_pages
  end
  
  root 'branches#index'
end
