class AddColumnWinnerToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :winner, :boolean
  end
end
