class GamesController < ApplicationController

  include GamesHelper

  before_action :authenticate_user!
  before_action :find_game, only: [:invite_friends, :edit, :update, :invite, :uninvite]
  before_action :find_invitee, only: [:invite, :uninvite]

  def index
  end

  def create
  	@game = Game.new
  	@game.creator = current_user
  	@game.save
  	redirect_to invite_friends_path(@game)
  end

  def show
  	#show the game once it is launched. Should redirect to pending_game until the 3 players have joined
  end

  def pending_game
  	#sends to the view that players should see until the 3 players have joined
  end

  def random_game

  end

  def update
  	#method used by players to go to the next turn and update the state of the game with their actions
  end 

  def invite_friends 
  end

  def invite
  	if @game.invitees.size < 2
	  	@game.invitees << @invitee

	  	respond_to do |format|
	      format.html { redirect_to invite_friends_path(@game) }
	      format.js
	    end
	else 
		flash[:danger] = 'You can only invite 2 players to the game'
		redirect_to invite_friends_path(@game)
	end	
  end

  def uninvite
  	@game.invitees.destroy(@invitee)

  	respond_to do |format|
      format.html { redirect_to invite_friends_path(@game) }
      format.js
    end
  end

  private

  def find_game
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	@game = Game.find(obfuscated_id.decode(params[:id]))[0]
  end

  def find_invitee
  	@invitee = User.find(params[:invitee_id])
  end

end
