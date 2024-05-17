# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'pages#index'

    resources :books
    resources :users, only: %i[new create edit update]
    resource :session, only: %i[new create destroy]
  end
end
