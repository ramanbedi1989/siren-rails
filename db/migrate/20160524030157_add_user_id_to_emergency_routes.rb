class AddUserIdToEmergencyRoutes < ActiveRecord::Migration[5.0]
  def change
    add_column :emergency_routes, :user_id, :integer
  end
end
