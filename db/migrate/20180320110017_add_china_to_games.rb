class AddChinaToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :china, :text
  end
end
