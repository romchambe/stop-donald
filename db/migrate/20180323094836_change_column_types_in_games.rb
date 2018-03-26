class ChangeColumnTypesInGames < ActiveRecord::Migration[5.1]
  def change
  	change_column :games, :us_army_forces, :text
    change_column :games, :rebels_forces, :text
  end
end
