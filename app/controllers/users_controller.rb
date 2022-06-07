# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :create

  def create; end

  def update; end

  def delete; end
end
