# frozen_string_literal: true

class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.integer :amountAvailable
      t.integer :cost
      t.string :productName

      t.timestamps
    end
  end
end
