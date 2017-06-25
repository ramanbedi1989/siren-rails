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

  def buzzfeed
    if current_user.present?
      if current_user.sufferer?
        if current_user.busy? && current_user.sufferer_emergency_routes.last.present? && current_user.sufferer_emergency_routes.last.healer.present?
          render json: { status: 'Help is on the way' }, status: 200
        elsif current_user.busy?
          render json: { status: 'We are searching for your help' }, status: 200
        else
          render json: { status: 'No buzzfeed for you' }, status: 200
        end
      elsif current_user.mediator?
        light_locations = Location.lights.limit(5)
        render json: { locations: light_locations }, status: 200
      elsif current_user.healer?
        if current_user.busy?
          if current_user.healer_emergency_routes.last.present?
          destination = current_user.healer_emergency_routes.last.locations.destinations.first
          gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_AUTH_KEY'])
          destination_location = gmaps.reverse_geocode([latitude, longitude]).first[:formatted_address]
          render json: { status: "Help required at #{destination_location}" }, status: 200
        else
          render json: { status: 'No buzzfeed for you' }, status: 200
        end
      else
        render json: { errors: ['current user does not belong to a valid category'] }, status: 404  
      end
    else
      render json: { errors: ['current user not found'] }, status: 404
    end
  end

  private
  def user_params
    params.permit(:email, :password, :password_confirmation, :category, :device_id)
  end
end
