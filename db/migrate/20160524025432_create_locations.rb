class CreateLocations < ActiveRecord::Migration[5.0]
  def change
    create_table :locations do |t|
      t.string :location_type
      t.integer :user_id
      t.integer :emergency_route_id
      t.integer :loc_index
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
  end
end
