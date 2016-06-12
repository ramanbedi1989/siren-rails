class AddBusyToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :busy, :boolean, default: false
  end
end
