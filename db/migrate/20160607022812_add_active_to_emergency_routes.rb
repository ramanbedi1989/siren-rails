class AddActiveToEmergencyRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :emergency_routes, :active, :boolean, default: false
  end
end
