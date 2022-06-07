# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { 'buyer_user' }
    password { 'test' }
    deposit { 10 }
    role { 'buyer' }
  end
end
