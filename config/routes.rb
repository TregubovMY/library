# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'pages#index'

    resources :books do
      resources :borrowings, only: [:create]
    end
    resources :borrowings, only: %i[index update]

    resources :users, only: %i[new create edit update]
    resource :session, only: %i[new create destroy]

    namespace :admin do
      resources :users, only: %i[index new create edit update destroy]
    end
  end
end
