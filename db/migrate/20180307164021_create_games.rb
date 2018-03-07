class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.integer :turn_number
      t.integer :us_army_force
      t.integer :rebels_force

      t.timestamps
    end
  end
end
