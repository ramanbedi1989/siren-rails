class EmergencyRoute < ApplicationRecord
  belongs_to :sufferer, class_name: 'User', foreign_key: :sufferer_id
  belongs_to :healer, class_name: 'User', foreign_key: :healer_id
  has_many :locations
  
  after_update :update_current_location_and_push

  def update_current_location_and_push
    if self.current_location_id_changed?
      notifapp = RailsPushNotifications::GCMApp.first
      gmaps = GoogleMapsService::Client.new(key: ENV['GOOGLE_AUTH_KEY'])
      notifapp.notifications.create(
        destinations: [self.locations.destinations.first.user.device_id], 
        data: {
          category: User::USER_CATEGORIES[0],
          emergency_route_id: self.id,
          donot_popup: true,
          current_location_id: self.current_location_id,
          purpose: "notifyLocationChanged"
        }
      )
      current_location_index = self.locations.find(self.current_location_id).loc_index
      suspected_traffic_light = self.locations.where(loc_index: (current_location_index+3)).first if current_location_index.present?
      if(suspected_traffic_light != nil && suspected_traffic_light.location_type == Location::VALID_TYPES[2] && !suspected_traffic_light.light_status) 
        notifapp.notifications.create(
          destinations: User.mediators.map(&:device_id), 
          data: {
            title: "Traffic Light Change Requested",
            message: "Click to view details",
            category: User::USER_CATEGORIES[1],
            emergency_route_id: self.id,
            light_location_id: suspected_traffic_light.id,
            location: gmaps.reverse_geocode([suspected_traffic_light.latitude, suspected_traffic_light.longitude]).first[:formatted_address]
          }
        )
      end
      notifapp.push_notifications
    end
  end
end
