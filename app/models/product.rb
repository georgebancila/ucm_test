# frozen_string_literal: true

class Product < ApplicationRecord
  belongs_to :seller, class_name: 'User'
  validates :productName, presence: true, uniqueness: true
  validates :amountAvailable, presence: true
  validates :cost, presence: true
  validate :valid_cost

  private

  def valid_cost
    errors.add(:cost, 'must be a multiple of 5!') if (cost % 5) != 0
  end
end
