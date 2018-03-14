class Game < ApplicationRecord

  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :players, class_name: 'User', join_table: 'games_users', 
  						  foreign_key: 'game_id', association_foreign_key: 'user_id', after_add: :broadcast_to_waiting_room
  has_and_belongs_to_many :invitees, class_name: 'User', join_table: 'game_invites_invitees', 
  						  association_foreign_key: 'game_invite_id', foreign_key: 'invitee_id'
  
  scope :created_by, ->(user) { where(creator_id: user) }
  scope :not_created_by, ->(user) { where.not(creator_id: user) }
  scope :pending, -> { where(status: "pending") }
  scope :ongoing, -> { where(status: "ongoing") }
  scope :finished, -> { where(status: "finished") }

  def to_param
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	obfuscated_id.encode(id)
  end

  def broadcast_to_waiting_room(player)
    game_id = self.id
    player_id = player.id
    NewPlayerBroadcastJob.perform_now game_id, player_id
  end
end
