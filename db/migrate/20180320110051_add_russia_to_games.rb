class AddRussiaToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :russia, :text
  end
end
