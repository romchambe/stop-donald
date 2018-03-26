class RenameColumnsInGames < ActiveRecord::Migration[5.1]
  def change
    rename_column :games, :us_army_force, :us_army_forces
    rename_column :games, :rebels_force, :rebels_forces
  end
end
