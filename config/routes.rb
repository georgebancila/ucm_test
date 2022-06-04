# frozen_string_literal: true

Rails.application.routes.draw do
  post 'purchases/buy'
  post 'purchases/deposit'
  post 'purchases/reset'
  resources :users, only: [:create] do
    post 'logout/all', to: 'users#logout_all'
  end
  resources :products, only: %i[create update delete show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
