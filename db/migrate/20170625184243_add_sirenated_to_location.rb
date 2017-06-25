class AddSirenatedToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :sirenated, :boolean
  end
end
