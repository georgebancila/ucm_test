# frozen_string_literal: true

require 'securerandom'

class User < ApplicationRecord
  has_secure_password
  ROLES = { buyer: 'buyer', seller: 'seller' }.freeze

  has_many :products, dependent: :destroy

  validates :password, presence: true
  validates :username, presence: true, uniqueness: true
end
