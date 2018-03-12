class Game < ApplicationRecord

  belongs_to :creator, class_name: 'User'
  has_and_belongs_to_many :players, class_name: 'User', join_table: 'games_users', 
  						  foreign_key: 'game_id', association_foreign_key: 'user_id'
  has_and_belongs_to_many :invitees, class_name: 'User', join_table: 'game_invites_invitees', 
  						  association_foreign_key: 'game_invite_id', foreign_key: 'invitee_id'
  
  scope :created_by, ->(user) { where(creator_id: user) }

  def to_param
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	obfuscated_id.encode(id)
  end

end
