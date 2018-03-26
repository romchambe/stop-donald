class GamesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_invitee, only: [:invite, :uninvite]
  before_action :find_game, only: [:show, :actions, :update, :invite, :cancel_action,
                                   :uninvite, :send_invites, :join, :destroy]
  before_action :find_player, only: [:actions, :update]

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
      if @game.status == "ongoing"
        find_player
      end
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



  def actions
    @player.update(status: params[:user_action])

    if params[:user_action] == 'recruit'
      render json: {selector: '#modal-form', user_action: params[:user_action], 
      msg: '', game_id: params[:id]}

    elsif params[:user_action] == 'mission'
      missionable_cities = get_missionable_cities @game, @player
      render json: {selector: '#cities', user_action: params[:user_action], 
      msg: missionable_cities, game_id: params[:id], max: @player.spies.length}

    elsif params[:user_action] == 'attack'
      attackable_cities = get_attackable_cities(@game)
      render json: {selector: '#cities', user_action: params[:user_action], 
        msg: attackable_cities, game_id: params[:id], max: 1}

    elsif params[:user_action] == 'reinforce'
      reinforcements = reinforcements_for(@player)
      render json: {selector: '#modal-form', user_action: params[:user_action], 
      msg: reinforcements, game_id: params[:id]}

    else
      flash[:danger] = 'This is not an allowed action'
      redirect_to game_path(@game)
    end
  end

  def cancel_action
    @player.update(status: 'pending_action')
    redirect_to game_path(@game)
  end

  def update
    #method used by players to go to the next turn and update the state of the game with their actions
    @player.update(status: 'updated')

    if params[:user_action] == 'recruit'
      
    elsif params[:user_action] == 'mission'
      
    elsif params[:user_action] == 'attack'
      
    elsif params[:user_action] == 'reinforce'
     
    else
      flash[:danger] = 'This is not an allowed action'
      redirect_to game_path(@game)
    end
  end 

  def next_turn
    if @game.turn_number % 5 == 0
      trump_moves(@game)
    end
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

  def find_player
    @player = Player.find_by(user_id: current_user.id) 
  end

  def find_invitee
  	@invitee = User.find(params[:invitee_id])
  end

  def game_params
    params.require(:game).permit(:creator_id, :status)
  end

end
