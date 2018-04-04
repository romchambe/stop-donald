class Player < ApplicationRecord
  belongs_to :user
  belongs_to :game
  has_many :messages, dependent: :destroy

  serialize :available_forces
  serialize :engaged_forces
  serialize :launch_sites
  serialize :spies

  after_create do |player|
  	NewPlayerBroadcastJob.perform_now player.game_id, 'player_joined', player.id 
  end 
end
