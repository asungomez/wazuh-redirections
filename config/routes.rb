Rails.application.routes.draw do
  
  resources :branches do
    put 'refresh', to: 'branches#refresh', on: :member
    get 'pages/new', to: 'branches#new_pages', on: :member, as: :new_pages
    get 'pages/deleted', to: 'branches#deleted_pages', on: :member, as: :deleted_pages
    get 'pages/renamed', to: 'branches#renamed_pages', on: :member, as: :renamed_pages
  end
  
  root 'branches#index'
end
