module GamesHelper
  include GameInitializerHelper
  
  TIMER_START = 60

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
                    timer: TIMER_START)
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

    game.turn_number += 1
    trump_city = ''
    killed_spies = {china: [], europe: [], russia: []}
    
    game.cities.select{ |k,v| 
      if v[:trump]
        trump_city = k
      end
    }

    casualties_caused = {rebels: 0.09, us_army: 0.03}

    #REBELLION MANAGEMENT -------------------------------------------------------------------------
    rebels_power = power_computer game.rebels_forces
    us_army_power = power_computer game.us_army_forces

    game.rebels_forces.each do |type, firepower|
      game.rebels_forces[type] = ((1.0 - casualties_caused[:us_army]) * firepower).round
    end

    game.us_army_forces.each do |type, firepower|
      game.us_army_forces[type] = ((1.0 - casualties_caused[:rebels]) * firepower).round
    end

    possible_conquests = cities_to_be_conquered(game)
    conquered_this_turn = []

    if rebels_power > 0.5 * (rebels_power + us_army_power) && rebels_power <= 0.6 * (rebels_power + us_army_power)
      1.times do 
        conquered = possible_conquests.slice!(0)
        game.cities[conquered][:conquered] = true
        conquered_this_turn << conquered.to_s.humanize.capitalize
      end
    elsif rebels_power > 0.6 * (rebels_power + us_army_power) && rebels_power <= 0.8 * (rebels_power + us_army_power)
      2.times do 
        conquered = possible_conquests.slice!(0)
        game.cities[conquered][:conquered] = true
        conquered_this_turn << conquered.to_s.humanize.capitalize
      end
    elsif rebels_power > 0.8 * (rebels_power + us_army_power) 
      3.times do 
        conquered = possible_conquests.slice!(0)
        game.cities[conquered][:conquered] = true
        conquered_this_turn << conquered.to_s.humanize.capitalize
      end
    end

    if !conquered_this_turn.empty?
      conquered_this_turn = conquered_this_turn.join(', ')

      game.players.each do |player|
        Message.create(player_id: player.id, read: false, 
                       content:"#{conquered_this_turn} were conquered by the rebels and their allies during the last turn",
                       turn_number: game.turn_number)
      end 
    end
    
    #SPIES MANAGEMENT -----------------------------------------------------------------------------
    if !game.cities[trump_city][:spies].empty? && rand_comparator?(0.7)

      game.cities[trump_city][:spies].each do |country, spy_name|
        player = game.players.find_by(country: country)
        if rand_comparator?(0.3)
          
          killed_spies[country] << spy_name
          game.cities[trump_city][:spies].delete(country)

          Message.create(player_id: player.id, read: false, 
                         content:"#{spy_name} was killed after having found Trump in #{trump_city}, and Trump moved to another city",
                         turn_number: game.turn_number)
        else 
          Message.create(player_id: player.id, read: false, 
                         content:"#{spy_name} found Trump in #{trump_city}, but Trump escaped!",
                         turn_number: game.turn_number)
        end

      end

      trump_moves(game)

    elsif game.cities[trump_city][:spies].empty? && game.turn_number % 3 == 1

      trump_moves(game)

    else

      game.cities[trump_city][:spies].each do |country, spy_name|
        player = game.players.find_by(country: country)
        Message.create(player_id: player.id, read: false, 
                       content:"#{spy_name} located Trump in #{trump_city}, don't let him escape!!",
                       turn_number: game.turn_number)
    
      end 

    end

    #SPIES RISK -----------------------------------------------------------------------------------
    
    spies_on_mission = get_spies_on_mission(game)

    spies_on_mission.each do |country, array_of_spies|
      player = game.players.find_by(country: country)
      array_of_spies.each do |spy_hash|
        
        if game.cities[spy_hash[:city]][:destroyed]

          game.cities[spy_hash[:city]][:spies].delete(country)
          killed_spies[country] << spy_hash[:name]
          

          Message.create(player_id: player.id, read: false, 
                       content:"#{spy_hash[:name]} was killed in #{spy_hash[:city]} as the city was destroyed by a nuclear attack",
                       turn_number: game.turn_number)
        
        elsif rand_comparator?(0.1)
          
          game.cities[spy_hash[:city]][:spies].delete(country)
          killed_spies[country] << spy_hash[:name]

          Message.create(player_id: player.id, read: false, 
                       content:"#{spy_hash[:name]} was killed in action by the CIA in #{spy_hash[:city]} without finding Trump",
                       turn_number: game.turn_number)
        end
      end 
    end

    #VICTORY MANAGEMENT ---------------------------------------------------------------------------

    if game.cities[trump_city][:destroyed]
      Player.find(game.cities[trump_city][:destroyed_by][0]).update(winner: true)
      game.status = 'finished'
    
    elsif game.cities[trump_city][:conquered]
      
      players_engaged_firepower = {}
      
      game.players.each do |player|
        player_power = power_computer player.engaged_forces
        players_engaged_firepower[player.country.to_sym] = player_power
      end

      game.players.where(country: players_engaged_firepower.key(players_engaged_firepower.values.max))[0].update(winner: true)
      game.status = 'finished'
    
    elsif game.turn_number == 13 
      game.status = 'finished'
    end

    #GAME AND PLAYERS UPDATES ---------------------------------------------------------------------------

    game.save

    game.players.each do |player| 
      killed_spies[player.country.to_sym].each do |spy_name|
  
        player.spies.select {|k,v| 
          if v[:name] == spy_name
            player.spies[k][:operational] = false
          end 
        }
      end
      
      player.engaged_forces.each do |type, firepower|
        player.engaged_forces[type] = ((1.0 - casualties_caused[:us_army]) * firepower).round
      end 

      if player.country.to_sym == :china && player.lost_cities > 9
        player.winner = false
      elsif player.country.to_sym != :china && player.lost_cities > 5
        player.winner = false
      end

      player.timer = TIMER_START
      player.status = 'pending_action' unless player.winner == false
      player.save
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

  def get_trump_city(game)
    game.cities.select{ |k,v| 
      if v[:trump]
        return k
      end
    }
  end

  def build_geojson(game,player)
    geojson = []
    
    CITIES_INITIALIZER.each do |name, attributes|

      spy_name = game.cities[name][:spies][player.country.to_sym]
      geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [attributes[:long], attributes[:lat]]
        },
        properties: {
          type: 'City',
          id: game.cities[name][:id],
          name: name,
          name_human: name.to_s.humanize.titleize,
          population: attributes[:pop], 
          destroyed: game.cities[name][:destroyed], 
          conquered: game.cities[name][:conquered],
          spies: spy_name
        }
      }
    end

    US_LAUNCH_SITES[:usa].each do |name, attributes|
      geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [attributes[:long], attributes[:lat]]
        },
        properties: {
          type: 'Launch Site',
          id: attributes[:id],
          name: name,
          name_human: name.to_s.humanize.titleize,
          destroyed: !game.launch_sites[name][:operational]
        }
      }
    end 

    return geojson 
  end
end
