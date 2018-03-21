class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.references :user, foreign_key: true
      t.references :game, foreign_key: true
      t.string :country
      t.string :username
      t.integer :lost_cities
      t.integer :lost_launch_sites
      t.text :launch_sites
      t.text :available_forces
      t.text :engaged_forces
      t.text :spies

      t.timestamps
    end
  end
end
