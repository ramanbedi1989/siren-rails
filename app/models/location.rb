class Location < ApplicationRecord
  VALID_TYPES = ["destination", "origin", "lights", "path"]
  NUMBER_OF_LIGHTS = 5

  belongs_to :emergency_route
  belongs_to :user

  scope :origins, lambda { where(location_type: Location::VALID_TYPES[1]) }
  scope :destinations, lambda { where(location_type: Location::VALID_TYPES[0]) }
  scope :lights, lambda { where(location_type: Location::VALID_TYPES[2]) }


  validate :only_one_destination_and_origin

  after_create :create_route_and_push

  after_update :check_light_status_and_push

  def create_route_and_push
    notifapp = RailsPushNotifications::GCMApp.first
    gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_AUTH_KEY'])
    if self.location_type == Location::VALID_TYPES[1]
      destination = emergency_route.locations.destinations.first
      routes = gmaps.directions({latitude: self.latitude, longitude: self.longitude},{latitude: destination.latitude, longitude: destination.longitude},mode: 'driving')
      emergency_route.update route_json: routes.to_json
      steps = routes[0][:legs].map{ |leg| leg[:steps].map { |step| GoogleMapsService::Polyline.decode(step[:polyline][:points]) } }.flatten
      traffic_light_index = steps.length / NUMBER_OF_LIGHTS
      traffic_light_indexes = []
      NUMBER_OF_LIGHTS.times { |index| traffic_light_indexes << (traffic_light_index * (index + 1)) }
      steps.each_with_index do |path, index|
        emergency_route.locations.create(latitude: path[:lat], longitude: path[:lng], location_type: (traffic_light_indexes.include?(index) ? Location::VALID_TYPES[2] : Location::VALID_TYPES[3]), loc_index: index)
      end
      notifapp.notifications.create(
        destinations: [emergency_route.locations.destinations.first.user.device_id], 
        data: {
          title: "Your help has started",
          message: "Click to view details",
          category: User::USER_CATEGORIES[0],
          emergency_route_id: emergency_route.id
        }
      )
    elsif self.location_type == Location::VALID_TYPES[0]
      active_healers = User.active_healers
      if active_healers.count > 0
        notifapp.notifications.create(
          destinations: active_healers.map(&:device_id), 
          data: {
            title: "A sufferer needs your help",
            message: "Click to view details",
            location: gmaps.reverse_geocode([latitude, longitude]).first[:formatted_address],
            category: User::USER_CATEGORIES[2],
            emergency_route_id: emergency_route.id
          }
        )
      end
    end
    notifapp.push_notifications
  end

  def check_light_status_and_push
    if light_status_changed? && location_type == Location::VALID_TYPES[2] && light_status
      notifapp = RailsPushNotifications::GCMApp.first
      gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_AUTH_KEY'])
      notifapp.notifications.create(
        destinations: [emergency_route.locations.origins.first.user.device_id], 
        data: {
          category: User::USER_CATEGORIES[2],
          emergency_route_id: self.emergency_route.id,
          donot_popup: true,
          lights_location_id: self.id,
          purpose: "notifyLightsChanged"
        }
      )
      notifapp.push_notifications
    end
  end

  def only_one_destination_and_origin
    if emergency_route.locations.origins.length > 1
      errors.add(:emergency_route, 'origin cannot be more than one.')
    elsif emergency_route.locations.destinations.length > 1
      errors.add(:emergency_route, 'destination cannot be more than one.')
    end
  end
end
