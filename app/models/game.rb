class Game < ApplicationRecord

  belongs_to :creator, class_name: 'User'
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_and_belongs_to_many :invitees, class_name: 'User', join_table: 'game_invites_invitees', 
  						  association_foreign_key: 'game_invite_id', foreign_key: 'invitee_id'
  
  serialize :cities
  serialize :us_army_forces
  serialize :rebels_forces
  serialize :launch_sites

  scope :created_by, ->(user) { where(creator_id: user) }
  scope :not_created_by, ->(user) { where.not(creator_id: user) }
  scope :pending, -> { where(status: "pending") }
  scope :ongoing, -> { where(status: "ongoing") }
  scope :not_finished, -> { where.not(status: "finished") }

  def to_param
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	obfuscated_id.encode(id)
  end

end
