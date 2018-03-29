class AddTimerToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :timer, :integer
  end
end
