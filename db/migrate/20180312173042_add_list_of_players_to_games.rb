class AddListOfPlayersToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :list_of_players, :text
  end
end
