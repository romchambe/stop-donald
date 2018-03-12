class AddUserToGames < ActiveRecord::Migration[5.1]
  def change
    add_reference :games, :creator, foreign_key: true
  end
end
