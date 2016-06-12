class AddLightStatusToLocations < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :light_status, :boolean, default: false
  end
end
