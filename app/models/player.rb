class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game

  serialize :available_forces
  serialize :engaged_forces
  serialize :launch_sites
  serialize :spies

  after_create do 
  	NewPlayerBroadcastJob.perform_now self.game.id, self.user.id
  end 
end
