class GamesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_game, only: [:show, :initializer, :update, :invite, :uninvite, :send_invites, :join,:destroy]
  before_action :find_invitee, only: [:invite, :uninvite]

  def index
  end

  def create
  	@game = Game.new(game_params)
  	if @game.save
  	  redirect_to game_path(@game)
    else
      flash[:danger] = 'An error occurred, please contact us at xyz@gmail.com'
      redirect_to games_path
    end
    Player.create(game_id: @game.id, user_id: current_user.id, username: User.find(current_user.id).username)
  end

  def show
  	#show the game once it is launched. Should redirect to pending_game until the 3 players have joined
    if @game.status == "invite_friends" && @game.creator != current_user
      flash[:danger] = 'The creator of this game needs to finish inviting players before you can join.'
      redirect_to games_path
    else
      render_partial_for(@game.status)
    end 
  end

  def random_game
    if random_game_available?
      @game = create_random_game(current_user)
    else 
      @game = join_random_game(current_user)
    end
    redirect_to game_path(@game)
  end

  def invite
  	if @game.invitees.size < 2
	  	@game.invitees << @invitee

	  	respond_to do |format|
	      format.html { redirect_to game_path(@game) }
	      format.js
	    end
	else 
		flash[:danger] = 'You can only invite 2 players to the game'
		redirect_to game_path(@game)
	end	
  end

  def uninvite
  	@game.invitees.destroy(@invitee)

  	respond_to do |format|
      format.html { redirect_to game_path(@game) }
      format.js
    end
  end

  def send_invites
    if @game.invitees.size == 2
      @game.update(status: "pending")
      redirect_to game_path(@game)
    else
      flash[:danger] = 'You need to invite 2 persons to this game'
      redirect_to game_path(@game)
    end
  end

  def join
    if @game.players.size < 3 && @game.players.where(user_id: current_user.id).empty?
      
      Player.create(game_id: @game.id, user_id: current_user.id, username: User.find(current_user.id).username)
      @game.invitees.delete(current_user)
      ready_to_start?(@game)
      
      redirect_to game_path(@game)
    end
  end

  def update
    #method used by players to go to the next turn and update the state of the game with their actions
  end 

  def destroy
    @game.destroy
    render 'index'
  end 

  def get_current_user
    @user = current_user
    render json: {id: @user.id}
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
