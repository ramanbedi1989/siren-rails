class AddCurrentLocationIdToEmergencyRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :emergency_routes, :current_location_id, :integer
  end
end
