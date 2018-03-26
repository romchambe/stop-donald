module GamesHelper
  include GameInitializerHelper
  
  def random_game_available?
  	Game.created_by(User.find(1)).pending.empty?
  end

  def join_random_game(user)
  	game = Game.created_by(User.find(1)).pending.first

  	if game.players.where(user_id: user.id).empty?
  		Player.create(game_id: game.id, user_id: user.id, username: User.find(user.id).username)
  	else
  		flash[:danger] = 'You are already part of a random game'
  	end

    ready_to_start?(game)

  	return game
  end

  def create_random_game(user)
  	game = Game.create(creator_id: 1, status: "pending")
  	Player.create(game_id: game.id, user_id: user.id, username: User.find(user.id).username)
  	return game
  end

  def render_partial_for(type)
    statuses = ["invite_friends","pending","ongoing"]
    status = statuses.include?(type) ? type : 'default'
    render "games/templates/#{status}" and return
  end

  def ready_to_start?(game)
    if game.players.size == 3
      game.update(status: "ongoing")
      get_started(game)
    end
  end

  def get_started(game)
    #A nation should be attributed to each player, and the country specific attributes are populated
    countries = [:china, :europe, :russia]
    players = game.players.shuffle.map.with_index do |player, i|
      player.update(country: countries[i], lost_cities: 0, lost_launch_sites: 0, 
                    launch_sites: LAUNCH_SITES_INITIALIZER[countries[i]], 
                    available_forces: FORCES_INITIALIZER[countries[i]], 
                    engaged_forces: {aircrafts: 0, tanks: 0}, 
                    spies: SPIES_INITIALIZER[countries[i]])
    end

    #Trump location is randomized
    trump_location = rand(25)
    counter = 0
    cities = CITIES_INITIALIZER

    #cities are initialised and saved as a game attribute
    cities.each do |city, properties|
      if counter == trump_location
        properties[:trump] = true
      else 
        properties[:trump] = false
      end
      properties[:id] = counter
      properties[:spies] = {}
      properties[:destroyed] = false
      properties[:conquered] = false
      counter += 1
    end
    game.update(turn_number: 1, cities: cities, us_army_forces: US_FORCES[:us_army], rebels_forces: REBELS_FORCES[:rebels], launch_sites: US_LAUNCH_SITES[:usa])
  end
  
  def get_missionable_cities(game, player)
    missionable_cities = {}
    game.cities.each do |city,properties|
      if !properties[:destroyed] && !properties[:conquered] && !properties[:spies].include?(player.country)
        missionable_cities[city] = {id: properties[:id]}
      end
    end
    return missionable_cities
  end

  def get_attackable_cities(game)
    attackable_cities = {}
    game.cities.each do |city,properties|
      if !properties[:destroyed] && !properties[:conquered]
        attackable_cities[city] = {id: properties[:id]}
      end
    end
    return attackable_cities
  end 
  
  def reinforcements_for(player)
    reinforcements = {aircrafts: 0, tanks: 0}
    if player.country.to_sym == :europe
      reinforcements[:aircrafts] = FORCES_INITIALIZER[player.country.to_sym][:aircrafts] / 4
      reinforcements[:tanks] = FORCES_INITIALIZER[player.country.to_sym][:tanks] / 4
    else
      reinforcements[:aircrafts] = FORCES_INITIALIZER[player.country.to_sym][:aircrafts] / 6
      reinforcements[:tanks] = FORCES_INITIALIZER[player.country.to_sym][:tanks] / 6
    end
    return reinforcements
  end
  
  def trump_moves(game)
    possible_locations = []
    
    game.cities.each do |city, properties|
      if !properties[:destroyed] && !properties[:conquered] && !properties[:trump]
        possible_locations << city
      elsif properties[:trump]
        properties[:trump] = false
      end
    end

    trump_location = rand(possible_locations.length)
    game.cities[possible_locations[trump_location]][:trump] = true 
    game.save  

    flash[:danger] = 'Trump has moved to a different city!'
  end
end
