class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.references :player, foreign_key: true
      t.text :content
      t.integer :turn_number
      t.boolean :read

      t.timestamps
    end
  end
end
