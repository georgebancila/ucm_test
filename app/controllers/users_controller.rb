# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create
  before_action :check_current_user
  skip_before_action :check_current_user, only: :create

  def create
    attributes = params.permit(:username, :password, :role, :deposit)
    user = User.new(attributes)
    user.save!
    render json: user.serialize, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    attributes = params.permit(:id, :username, :password, :role, :deposit)
    current_user.update(attributes)
    current_user.save!
    render json: current_user.serialize, status: :accepted
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    current_user.destroy!

    head :no_content
  end

  def show
    render json: current_user.serialize
  end

  private

  def check_current_user
    return if params[:id].to_i == current_user.id

    render json: { error: 'You are allowed to see/edit/delete only your user' }, status: :unauthorized
    false
  end
end
