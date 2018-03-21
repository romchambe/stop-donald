class RemoveRussiaFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :russia, :text
  end
end
