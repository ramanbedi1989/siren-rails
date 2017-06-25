class Api::V1::SessionsController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_with_token!, only: :create

  def create
    email = params[:session][:email]
    password = params[:session][:password]
    device_id = params[:device_id]
    user = email.present? ? User.find_by(email: email) : nil
    if user.present? && user.valid_password?(password)
      sign_in user, store: false
      user.generate_authentication_token!
      user.busy = false
      user.device_id = device_id
      user.save
      render json: user, status: 200
    else
      render json: { errors: 'Invalid Email or Password' }, status: 422
    end
  end

  def destroy
    user = current_user
    sign_out user
    user.generate_authentication_token!
    user.save
    head 204
  end

end
