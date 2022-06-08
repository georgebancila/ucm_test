# frozen_string_literal: true

require 'jwt'

module AuthConcern
  extend ActiveSupport::Concern
  included do
    before_action :authenticate_request

    private

    def authenticate_request
      header = request.headers['Authorization']
      header = header.split.last if header
      @decoded = jwt_decode(header)
      current_user
    rescue JWT::ExpiredSignature
      render json: { error: 'Token expired, issue another' }, status: :unauthorized
    rescue JWT::DecodeError
      render json: { error: 'Token is not valid' }, status: :unauthorized
    end

    def current_user
      @current_user ||= User.find(@decoded[:user_id])
    end
  end
end
