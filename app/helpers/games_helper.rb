module GamesHelper
  def random_game_available?
  	Game.created_by(User.find(1)).pending.empty?
  end

  def join_random_game(user)
  	game = Game.created_by(User.find(1)).pending.first
  	game.players << user
  	if game.players.size == 3
  	  game.update(status: "ongoing")
  	end
  	return game
  end

  def create_random_game(user)
  	game = Game.create(creator_id: 1, status: "pending")
  	game.players << user
  	return game
  end
end
