# frozen_string_literal: true

require 'securerandom'

class User < ApplicationRecord
  has_secure_password
  ROLES = { buyer: 'buyer', seller: 'seller' }.freeze

  has_many :products, dependent: :destroy, foreign_key: 'seller_id', inverse_of: :seller

  attribute :deposit, default: 0
  validate :valid_cost

  validates :password, length: { minimum: 6 }, allow_blank: true
  validates :username, presence: true, uniqueness: true
  validates :role, presence: true, inclusion: { in: %w[buyer seller] }

  def serialize
    {
      id: id,
      username: username,
      deposit: deposit,
      role: role,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def valid_cost
    errors.add(:deposit, 'must be a multiple of 5!') if (deposit % 5) != 0
  end
end
