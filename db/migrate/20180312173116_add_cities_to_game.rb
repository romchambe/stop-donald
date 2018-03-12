class AddCitiesToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :cities, :text
  end
end
