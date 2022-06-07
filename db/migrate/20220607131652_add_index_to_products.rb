# frozen_string_literal: true

class AddIndexToProducts < ActiveRecord::Migration[6.1]
  def change
    add_index :products, :productName, unique: true
  end
end
