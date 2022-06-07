# frozen_string_literal: true

class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: :login

  def login
    @user = User.find_by(username: params[:username])
    if @user
      if @user.authenticate(params[:password])
        token = jwt_encode(user_id: @user.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: 'unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'not_found' }, status: :not_found
    end
  end

  def logout_all; end
end
