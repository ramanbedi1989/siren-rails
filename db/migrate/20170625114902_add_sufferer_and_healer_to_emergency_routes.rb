class AddSuffererAndHealerToEmergencyRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :emergency_routes, :sufferer_id, :integer
    add_column :emergency_routes, :healer_id, :integer
  end
end
