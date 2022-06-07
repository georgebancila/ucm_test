# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    amountAvailable { 10 }
    cost { 5 }
    productName { 'Product' }
    seller { create(:user, username: 'seller_user', role: 'seller') }
  end
end
