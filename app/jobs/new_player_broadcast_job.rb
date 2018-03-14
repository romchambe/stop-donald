class NewPlayerBroadcastJob < ApplicationJob
  queue_as :default

  def perform(game,player)
  	player_username = User.find(player).username
  	obfuscated_id = Hashids.new("l'art de la guerre", 8)
    ActionCable.server.broadcast "waiting_room_#{game}", 
    							 {message: "#{player_username} has just joined the game!", 
    							 game_id: obfuscated_id.encode(game)}
  end
end
