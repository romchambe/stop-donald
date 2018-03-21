class AddEuropeToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :europe, :text
  end
end
