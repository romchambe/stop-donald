class AddUserToGames < ActiveRecord::Migration[5.1]
  def change
    add_reference :games, :creator
  end
end
