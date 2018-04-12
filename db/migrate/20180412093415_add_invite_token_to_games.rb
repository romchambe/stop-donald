class AddInviteTokenToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :invite_token, :string
  end
end
