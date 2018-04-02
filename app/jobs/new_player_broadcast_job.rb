class NewPlayerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game,event,*args)
    if event == 'player_joined'
    	player_username = Player.find(args[0]).username
    	players_count = Game.find(game).players.size
    	obfuscated_id = Hashids.new("l'art de la guerre", 8)

      ActionCable.server.broadcast "waiting_room_#{game}", 
      							{ 
                      event: event,
                      message: "#{player_username} has just joined the game!", 
                      username: player_username,
      							  game_id: obfuscated_id.encode(game),
      							  players_count: players_count
                    }
    elsif event == 'player_updated'
      player_username = Player.find(args[0]).country.capitalize
      players_count = Game.find(game).players.where(status: 'updated').size
      obfuscated_id = Hashids.new("l'art de la guerre", 8)

      ActionCable.server.broadcast "waiting_room_#{game}", 
                    { 
                      event: event,
                      message: "#{player_username} just played!", 
                      username: player_username,
                      game_id: obfuscated_id.encode(game),
                      players_count: players_count
                    }
    elsif event == 'next_turn'
      obfuscated_id = Hashids.new("l'art de la guerre", 8)

      ActionCable.server.broadcast "waiting_room_#{game}", 
                    { 
                      event: event,
                      game_id: obfuscated_id.encode(game),
                    }
    end
  end
end
