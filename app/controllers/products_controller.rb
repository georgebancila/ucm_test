# frozen_string_literal: true

class ProductsController < ApplicationController
  before_action :set_product, only: %i[show update destroy]
  before_action :check_seller
  skip_before_action :check_seller, only: %i[create show index]

  def create
    unless current_user.role == User::ROLES[:seller]
      render json: { error: 'Only a seller user can add products' }, status: :method_not_allowed
      return
    end

    attributes = params.permit(:amountAvailable, :cost, :productName)
    product = Product.new(attributes)
    product.seller = current_user
    product.save!
    @product = product
    render json: @product, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def index
    render json: Product.all
  end

  def show
    render json: @product
  end

  def update
    attributes = params.permit(:amountAvailable, :cost, :productName)
    @product.update(attributes)
    @product.save!
    render json: @product, status: :accepted
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def destroy
    @product.destroy!

    head :no_content
  end

  private

  def set_product
    @product = Product.find(params[:id])
  rescue StandardError
    render json: { error: "There is no product with id #{params[:id]}" }, status: :not_found
  end

  def check_seller
    return unless current_user.id != @product.seller.id

    render json: { error: 'Only the seller of this product can modify it' }, status: :method_not_allowed
  end
end
