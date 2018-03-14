module GamesHelper
  def random_game_available?
  	Game.created_by(User.find(1)).pending.empty?
  end

  def join_random_game(user)
  	game = Game.created_by(User.find(1)).pending.first

  	if !game.players.include?(user)
  		game.players << user
  	else
  		flash[:danger] = 'You are already part of a random game'
  	end

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

  def render_partial_for(type)
    statuses = ["invite_friends","pending","ongoing"]
    status = statuses.include?(type) ? type : 'default'
    render "games/templates/#{status}" and return
  end
end
