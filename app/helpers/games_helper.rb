module GamesHelper
  include GameInitializerHelper
  
  def random_game_available?
  	Game.created_by(User.find(1)).pending.empty?
  end

  def join_random_game(user)
  	game = Game.created_by(User.find(1)).pending.first

  	if game.players.where(user_id: user.id).empty?
  		Player.create(game_id: game.id, user_id: user.id, 
                    username: User.find(user.id).username, status:'pending_action')
  	else
  		flash[:danger] = 'You are already part of a random game'
  	end

    ready_to_start?(game)

  	return game
  end

  def create_random_game(user)
  	game = Game.create(creator_id: 1, status: "pending")
  	Player.create(game_id: game.id, user_id: user.id, 
                  username: User.find(user.id).username, status:'pending_action')
  	return game
  end

  def render_partial_for(type)
    statuses = ["invite_friends","pending","ongoing","updated"]
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
    game.players.shuffle.map.with_index do |player, i|
      player.update(country: countries[i], lost_cities: 0, lost_launch_sites: 0, 
                    launch_sites: LAUNCH_SITES_INITIALIZER[countries[i]], 
                    available_forces: FORCES_INITIALIZER[countries[i]], 
                    engaged_forces: {aircrafts: 0, tanks: 0}, 
                    spies: SPIES_INITIALIZER[countries[i]], 
                    winner: nil,
                    timer: 30)
    end

    #Trump location is randomized
    trump_location = rand(25)
    puts trump_location
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
      properties[:destroyed_by] = []
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

    game.launch_sites.each do |site, properties|
      if properties[:operational]
        attackable_cities[site] = {id: properties[:id]}
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

  def next_turn(game)

    trump_city = ''
    game.cities.select{ |k,v| 
      if v[:trump]
        trump_city = k
      end
    }
    casualties_caused = {rebels: 0.09, us_army: 0.03}

    #REBELLION MANAGEMENT -------------------------------------------------------------------------
    rebels_power = power_computer game.rebels_forces
    us_army_power = power_computer game.us_army_forces

    game.players.each do |player|
      player.engaged_forces.each do |type, firepower|
        player.engaged_forces[type] = ((1.0 - casualties_caused[:us_army]) * firepower).round
      end 
      player.save
    end

    game.rebels_forces.each do |type, firepower|
      game.rebels_forces[type] = ((1.0 - casualties_caused[:us_army]) * firepower).round
    end

    game.us_army_forces.each do |type, firepower|
      game.us_army_forces[type] = ((1.0 - casualties_caused[:rebels]) * firepower).round
    end

    possible_conquests = cities_to_be_conquered(game)

    if rebels_power > 0.5 * (rebels_power + us_army_power) && rebels_power <= 0.6 * (rebels_power + us_army_power)
      1.times do 
        game.cities[possible_conquests.slice!(0)][:conquered] = true
      end
    elsif rebels_power > 0.6 * (rebels_power + us_army_power) && rebels_power <= 0.8 * (rebels_power + us_army_power)
      2.times do 
        game.cities[possible_conquests.slice!(0)][:conquered] = true
      end
    elsif rebels_power > 0.8 * (rebels_power + us_army_power) 
      3.times do 
        game.cities[possible_conquests.slice!(0)][:conquered] = true
      end
    end

    game.save

    #VICTORY MANAGEMENT ---------------------------------------------------------------------------

    game.players.each do |player|
      if player.country.to_sym == :china && player.lost_cities > 9
        player.update(winner: false)
      elsif player.lost_cities > 5
        player.update(winner: false)
      end
    end 

    if game.cities[trump_city][:destroyed]
      Player.find(game.cities[trump_city][:destroyed_by][0]).update(winner: true)
      game.update(status: 'finished')
    
    elsif game.cities[trump_city][:conquered]
      
      players_engaged_firepower = {}
      game.players.each do |player|
        player_power = power_computer player.engaged_forces
        players_engaged_firepower[player.country.to_sym] = player_power
      end

      game.players.where(country: players_engaged_firepower.key(players_engaged_firepower.values.max))[0].update(winner: true)
      game.update(status: 'finished')
    
    elsif game.turn_number == 13 
      game.update(status: 'finished')
    end
    
    #SPIES MANAGEMENT -----------------------------------------------------------------------------
    if !game.cities[trump_city][:spies].empty? && rand_comparator?(0.7)

      game.cities[trump_city][:spies].each do |country, spy_name|
        player = game.players.find_by(country: country)
        if rand_comparator?(0.3)
          kill_spy(player, spy_name, trump_city, game)
          #send message that spy has been killed and trump has moved
        end
      end

      trump_moves(game)

    elsif game.cities[trump_city][:spies].empty? && game.turn_number % 3 == 1

      trump_moves(game)

    else

      spies_countries = game.cities[trump_city][:spies].keys
      spies_countries.each do |country|
        
          #send message that trump was located
    
      end 

    end

    #SPIES RISK -----------------------------------------------------------------------------------
    
    spies_on_mission = get_spies_on_mission(game)

    spies_on_mission.each do |country, array_of_spies|
      player = game.players.find_by(country: country)
      array_of_spies.each do |spy_hash|
        if rand_comparator?(0.1)
          kill_spy(player, spy_hash[:name], spy_hash[:city], game)
        end
      end 
    end
  end

  def rand_comparator?(probability)
    random_factor = rand()
    if random_factor < probability
      return true
    else 
      return false
    end 
  end

  def power_computer(forces)
    weapon_powers = {aircrafts: 3, tanks: 2}
    firepower = 0
    forces.each {|type, power| firepower += power * weapon_powers[type]}
    return firepower
  end

  def get_spies_on_mission(game)
    spies_on_mission = {china: [], europe: [], russia: []}
    game.cities.select { |city_name, attributes| 
      if !attributes[:spies].empty? 
        attributes[:spies].each do |country, spy_name|
          spies_on_mission[country] << { name: spy_name, city: city_name }
        end
      end
    }
    return spies_on_mission
  end

  def kill_spy(player, spy_name, city, game)
    player.spies.select {|k,v| 
      if v[:name] == spy_name
        player.spies[k][:operational] = false
        game.cities[city][:spies].delete(player.country.to_sym)
      end 
    }
    game.save
    player.save
  end

  def can_attack?(launch_sites)
    can_attack = false
    launch_sites.select{ |k,v| 
      if v[:operational]
        can_attack = true
      end 
    }
    return can_attack
  end

  def can_reinforce?(available_forces)
    return !(available_forces[:aircrafts] == 0)
  end

  def cities_to_be_conquered(game)
    destroyed_or_conquered = []

    game.cities.each do |city, properties|
      if properties[:destroyed] || properties[:conquered]
        destroyed_or_conquered << city
      end
    end

    possible_conquests = CITIES_TO_BE_CONQUERED
    return possible_conquests.select {|v| !destroyed_or_conquered.include?(v) }
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
  end
end
