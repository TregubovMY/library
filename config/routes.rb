Rails.application.routes.draw do
  root 'pages#index'

  resources :books
  resources :users, only: %i[new create]
  resource :session, only: %i[new create destroy]
end
