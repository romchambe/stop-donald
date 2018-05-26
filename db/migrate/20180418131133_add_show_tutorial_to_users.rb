class AddShowTutorialToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :show_tutorial, :boolean
  end
end
