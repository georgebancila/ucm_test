# frozen_string_literal: true

class AddSellerRelationToProducts < ActiveRecord::Migration[6.1]
  def change
    add_reference :products, :seller, index: true
    add_foreign_key :products, :users, column: :seller_id
  end
end
