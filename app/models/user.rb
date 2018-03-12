class User < ApplicationRecord

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates :username, presence: true, length: { maximum: 50 } 
  
  #Associations
  has_many :created_games, class_name: 'Game', foreign_key: 'creator_id'
  has_and_belongs_to_many :games
  has_and_belongs_to_many :game_invites, class_name: 'Game', join_table: 'game_invites_invitees', 
  						  foreign_key: 'game_invite_id', association_foreign_key: 'invitee_id'

  scope :all_except, ->(user) { where.not(id: user) }

  # def send_devise_notification(notification, *args)
	 #  devise_mailer.send(notification, self, *args).deliver_later
  # end
end
