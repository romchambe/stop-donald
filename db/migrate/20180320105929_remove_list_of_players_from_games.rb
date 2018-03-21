class RemoveListOfPlayersFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :list_of_players, :text
  end
end
