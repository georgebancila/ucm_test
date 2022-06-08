# frozen_string_literal: true

class PurchasesController < ApplicationController
  before_action :check_buyer_role

  def buy
    attributes = params.permit(:product_id, :amount)

    response = PurchasesService.buy(attributes, current_user)

    render json: response, status: :ok
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def deposit
    PurchasesService.validate_number('coin', params[:coin])

    coin = params[:coin].to_i

    unless PurchasesService::ACCEPTED_COINS.include?(coin)
      raise PurchasesService::CoinNotAcceptedError,
            "Coin not accepted, must be included in #{PurchasesService::ACCEPTED_COINS}"
    end

    current_user.deposit += coin
    current_user.save!

    head :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def reset
    change = PurchasesService.divide_amount(current_user.deposit)
    current_user.deposit = 0
    current_user.save!

    render json: { change: change.sort }, status: :ok
  end

  private

  def check_buyer_role
    return if current_user.role == User::ROLES[:buyer]

    render json: { error: 'Only users with buyer role can make purchases' }, status: :unauthorized
    false
  end
end
