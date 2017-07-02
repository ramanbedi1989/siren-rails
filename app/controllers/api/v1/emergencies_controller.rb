class Api::V1::EmergenciesController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_with_token!, only: :traffic_light_details

  def show
    current_route = EmergencyRoute.find params[:id]
    render json: { emergency_route_id: current_route.id, locations: current_route.locations }, status: 200
  end

  def create_destination
    current_user.update(busy: true)
    emergency_route = current_user.sufferer_emergency_routes.create
    location = emergency_route.locations.create(location_params.merge(location_type: Location::VALID_TYPES[0], user_id: current_user.id))
    render json: { emergency_route_id: emergency_route.id }, status: 201
  end

  def create_origin
    current_user.update(busy: true)
    current_route = EmergencyRoute.find(params[:id])
    current_destination = current_route.locations.destinations.first
    origin_lat = current_destination.latitude + rand * 0.05
    origin_lng = current_destination.longitude + rand * 0.05
    current_route.update(active: true, healer: current_user)
    current_route.locations.create(latitude: origin_lat, longitude: origin_lng, location_type: Location::VALID_TYPES[1], user_id: current_user.id)
    render json: { latitude: origin_lat, longitude: origin_lng }, status: 201
  end

  def update_location
    current_route = EmergencyRoute.find(params[:id])
    current_location_id = params[:location_id]
    if current_location_id.present?
      current_route.update(current_location_id: current_location_id)
      render nothing: true, status: 204
    else
      render json: {errors: ['Unable to find location Id']}, status: 404
    end
  end

  def switch_traffic_light
    current_route = EmergencyRoute.find(params[:id])
    location = Location.find(params[:location_id]) rescue nil
    if location.present?
      location.update(light_status: true, user_id: current_user.id, sirenated: true)
      ResetTrafficLightJob.set(wait: 1.minute).perform_later(location)
      render nothing: true, status: 204
    else
      render json: {errors: ['Unable to find location Id']}, status: 404
    end
  end

  def traffic_light_details
    current_route = EmergencyRoute.find(params[:id]) rescue nil
    #current implementation to turn green on any light being changed on the route.
    if current_route.present?
      if(current_route.locations.where(light_status: true).count > 0) 
        render json: {light_status: 1}, status: 200
      else
        render json: {light_status: 0}, status: 200
      end
    else
      render json: {errors: ['Unable to find current route'], light_status: 0}, status: 200
    end
  end

  def location_params
    params.permit(:latitude, :longitude)
  end
end