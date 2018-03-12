class AddLaunchSitesToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :launch_sites, :text
  end
end
