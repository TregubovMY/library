# frozen_string_literal: true

Rails.application.routes.draw do
  scope '(:locale)', locale: /#{I18n.available_locales.join('|')}/ do
    root 'pages#index'

    resources :books

    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }

    authenticate :user, ->(user) { user.user_role? } do
      scope '/books/:book_id' do
        resources :borrowings, only: [:create]
      end

      resources :borrowings, only: %i[index update]
    end

    authenticate :user, ->(user) { user.admin_role? } do
      namespace :admin do
        resources :users, only: %i[index new create edit update destroy] do
          member do
            patch :restore
          end
        end
      end

      resources :books do
        member do
          patch :restore
        end
      end
    end
  end
end
