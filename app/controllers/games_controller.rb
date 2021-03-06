class GamesController < ApplicationController

  before_action :authenticate_user!
  before_action :find_invitee, only: [:invite, :uninvite]
  before_action :find_game, only: [:show, :actions, :update, :invite, :cancel_action, :get_invite_token,
                                   :uninvite, :send_invites, :join, :destroy, :map, :timer_update]

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
    Player.create(game_id: @game.id, user_id: current_user.id, 
                  username: User.find(current_user.id).username, status:'pending_action')
  end

  def show
  	#show the game once it is launched. Should redirect to pending_game until the 3 players have joined

    if params[:invite_token] == @game.invite_token && @game.players.size < 3 && @game.players.where(user_id: current_user.id).empty?
      Player.create(game_id: @game.id, user_id: current_user.id, 
                    username: User.find(current_user.id).username, status:'pending_action')
      creator = @game.creator.username
      flash[:info] = "You have joined the game on an invite by #{creator}"
      ready_to_start?(@game)
      return redirect_to game_path(@game)
    end 

    if !find_player(@game)
      flash[:danger] = 'You are not one of the players of this game'
      redirect_to games_path
    elsif @game.status == 'invite_friends' && current_user != @game.creator
      render_partial_for("pending")
    elsif @game.status == 'ongoing' && @player.status == 'updated'
      render_partial_for(@player.status)
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
    if @game.invitees.size == 2 || params[:type] == 'invite_link'
      @game.update(status: "pending")
      redirect_to game_path(@game)
    else
      flash[:danger] = 'You need to invite 2 persons to this game'
      redirect_to game_path(@game)
    end
  end

  def join
    if @game.players.size < 3 && @game.players.where(user_id: current_user.id).empty?
      
      Player.create(game_id: @game.id, user_id: current_user.id, 
                    username: User.find(current_user.id).username, status:'pending_action')
      @game.invitees.delete(current_user)
      ready_to_start?(@game)
      
      redirect_to game_path(@game)
    end
  end

  def actions
    find_player(@game)
    @player.update(status: params[:user_action])

    if params[:user_action] == 'recruit'
      render json: {selector: '#modal-form', user_action: params[:user_action], 
      msg: '', game_id: params[:id]}

    elsif params[:user_action] == 'mission'
      available_spies = @player.spies.select {|key, value| value[:operational]}
      missionable_cities = get_missionable_cities @game, @player
      render json: {selector: '#cities', user_action: params[:user_action], 
      msg: missionable_cities, game_id: params[:id], max: available_spies.length}

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
    find_player(@game)
    @player.update(status: 'pending_action')
    redirect_to game_path(@game)
  end

  def update
    #method used by players to go to the next turn and update the state of the game with their actions
    find_player(@game)


    #Manage Actions
    if params[:user_action] == 'recruit'
      id = @player.spies.length
      @player.spies[id] = {name: params[:spy][:name], operational: true}
    
    elsif params[:user_action] == 'mission'
      # "targets"=>{"0"=>"New_York", "1"=>"Los_Angeles"}
      if !params[:targets].nil?
        @game.cities.each {
          |city, attributes| attributes[:spies].delete_if { |country, name| country == @player.country.to_sym }
        }
    
        available_spies = @player.spies.select {|key, value| value[:operational]}
        keys = available_spies.keys

        counter = 0
        params[:targets].each do |city_id, name|
          @game.cities[name.to_sym][:spies][@player.country.to_sym] = available_spies[keys[counter]][:name]
          counter += 1
        end
      else
        flash[:danger] = 'You need to select some cities on the map!'
        return redirect_to game_path(@game)
      end 
    
    elsif params[:user_action] == 'attack'

      if !params[:targets].nil?
        params[:targets].each do |city_id, name|
          if city_id.to_i > 24
            @game.launch_sites[name.to_sym][:operational] = false
          else
            @game.cities[name.to_sym][:destroyed] = true
            @game.cities[name.to_sym][:destroyed_by] << @player.id
          end
        end 
      else
        flash[:danger] = 'You need to select some cities on the map!'
        return redirect_to game_path(@game)
      end

      #retaliation

      if can_attack?(@game.launch_sites)
        @player.launch_sites[@player.launch_sites.to_a[@player.lost_launch_sites][0]][:operational] = false
        @player.lost_cities += 2
        @player.lost_launch_sites += 1
      end 

    elsif params[:user_action] == 'reinforce'

      if can_reinforce?(@player.available_forces)
        reinforcements = reinforcements_for(@player)
        reinforcements.each do |key, strength|
          @game.rebels_forces[key] += strength
          @player.engaged_forces[key] += strength
          @player.available_forces[key] -= strength
        end
      
      else 
        flash[:danger] = "You don't have any more troops to send"
        return redirect_to game_path(@game)
      end

    elsif params[:user_action] == 'pass'
      flash[:danger] = 'You did not take any action in time'

    else
      flash[:danger] = 'This is not an allowed action'
    end
    
    #Manage whether going to next turn or waiting
    if @game.players.where(status: 'updated').size < 2
      
      @player.status = 'updated'
      @player.save
      @game.save
      NewPlayerBroadcastJob.perform_now @player.game_id, 'player_updated', @player.id

    elsif @game.players.where(status: 'updated').size == 2
      
      @player.save
      next_turn(@game)
      NewPlayerBroadcastJob.perform_now @player.game_id,'next_turn'

    end 

    redirect_to game_path(@game)
  end 

  def destroy
    @game.destroy
    render 'index'
  end 

  def get_current_user
    @user = current_user
    render json: {id: @user.id}
  end

  def get_invite_token
    if @game.invite_token.nil?
      token = create_random_token
      @game.update(invite_token: token)
    end 

    render json: {token: @game.invite_token}
  end

  def map
    find_player(@game)
    geojson = build_geojson @game, @player
    render json: geojson
  end

  def timer_update
    find_player(@game)
    @player.update(timer: params[:value])
  end

  private

  def find_game
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
  	@game = Game.find(obfuscated_id.decode(params[:id]))[0]
  end

  def find_player(game)
    @player = Player.find_by(user_id: current_user.id, game_id: game.id) 
  end

  def find_invitee
  	@invitee = User.find(params[:invitee_id])
  end

  def game_params
    params.require(:game).permit(:creator_id, :status)
  end

end
