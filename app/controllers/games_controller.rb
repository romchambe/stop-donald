class GamesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_game, only: [:invite_friends, :edit, :update, :invite, :uninvite, :join, :pending_game,:destroy]
  before_action :find_invitee, only: [:invite, :uninvite]

  def index
  end

  def create
  	@game = Game.new(game_params)
  	if @game.save
  	  redirect_to invite_friends_path(@game)
    else
      flash[:danger] = 'An error occurred, please contact us at xyz@gmail.com'
      redirect_to games_path
    end
    @game.players << current_user
  end

  def show
  	#show the game once it is launched. Should redirect to pending_game until the 3 players have joined
  end

  def random_game
    if random_game_available?
      @game = create_random_game(current_user)
    else 
      @game = join_random_game(current_user)
    end
    redirect_to pending_game_path(@game)
  end

  def invite_friends 
    if current_user != @game.creator
      flash[:danger] = 'Since you are not the creator of the game, you cannot invite players'
      redirect_to games_path
    end
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

  def pending_game
    #sends to the view that players should see until the 3 players have joined
  end

  def join
    if @game.players.size < 3
      
      if @game.players << current_user
        ActionCable.server.broadcast 'WaitingRooms',
          players_count: @game.players.size,
          user: current_user.username
        head :ok
      end 
      
      @game.invitees.delete(current_user)
      
      if @game.players.size == 3
        @game.update(status: "ongoing")
        ActionCable.server.broadcast 'WaitingRooms',
          status: @game.status
        head :ok
      end
      
      redirect_to pending_game_path(@game)
    
    else 
    
      flash[:danger] = 'this game is already complete'
      redirect_to games_path
    
    end
  end

  def update
    #method used by players to go to the next turn and update the state of the game with their actions
  end 

  def destroy
    @game.destroy
    render 'index'
  end 

  private

  def find_game
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	@game = Game.find(obfuscated_id.decode(params[:id]))[0]
  end

  def find_invitee
  	@invitee = User.find(params[:invitee_id])
  end

  def game_params
    params.require(:game).permit(:creator_id, :status)
  end

end
