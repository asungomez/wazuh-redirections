Rails.application.routes.draw do
  
  resources :branches do
    put 'refresh', to: 'branches#refresh', on: :member
    get 'pages/new', to: 'branches#new_pages', on: :member, as: :new_pages
    get 'pages/deleted', to: 'branches#deleted_pages', on: :member, as: :deleted_pages
    get 'pages/renamed', to: 'branches#renamed_pages', on: :member, as: :renamed_pages
  end

  get 'branches/:branch_id/pages/:page_id/redirection', to: 'pages#edit_redirection', as: :edit_redirection
  post 'rename-page', to: 'pages#rename_page', as: :rename_page
  post 'new-page/:page_id', to: 'pages#mark_as_new', as: :new_page
  
  root 'branches#index'
end
