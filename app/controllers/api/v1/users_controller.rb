class Api::V1::UsersController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_with_token!, only: :create

  def show
    respond_with User.find(params[:id])
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  private
  def user_params
    params.permit(:email, :password, :password_confirmation, :category, :device_id)
  end
end
