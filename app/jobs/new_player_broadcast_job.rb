class NewPlayerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game,player)
  	player_username = User.find(player).username
  	players_count = Game.find(game).players.size
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
    ActionCable.server.broadcast "waiting_room_#{game}", 
    							 {message: "#{player_username} has just joined the game!", 
                   username: player_username,
    							 game_id: obfuscated_id.encode(game),
    							 players_count: players_count}
  end
end
