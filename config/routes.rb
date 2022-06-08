# frozen_string_literal: true

Rails.application.routes.draw do
  post '/buy', to: 'purchases#buy'
  post '/deposit', to: 'purchases#deposit'
  post '/reset', to: 'purchases#reset'
  resources :users, only: %i[create update destroy show]
  resources :products, only: %i[index create update destroy show]
  post '/login', to: 'authentication#login'
  post '/logout/all', to: 'authentication#logout_all'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
