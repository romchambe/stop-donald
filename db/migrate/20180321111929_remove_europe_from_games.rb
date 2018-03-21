class RemoveEuropeFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :europe, :text
  end
end
