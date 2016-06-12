class CreateEmergencyRoutes < ActiveRecord::Migration[5.0]
  def change
    create_table :emergency_routes do |t|
      t.text :route_json

      t.timestamps
    end
  end
end
