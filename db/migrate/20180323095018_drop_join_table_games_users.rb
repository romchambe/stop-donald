class DropJoinTableGamesUsers < ActiveRecord::Migration[5.1]
  def change
    drop_join_table :games, :users
  end
end
