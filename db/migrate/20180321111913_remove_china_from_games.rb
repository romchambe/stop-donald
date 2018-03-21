class RemoveChinaFromGames < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :china, :text
  end
end
