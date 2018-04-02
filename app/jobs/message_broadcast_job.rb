class MessageBroadcastJob
  def perform(player,action,*targets)
	if action == 'pass'
      message = "#{player_username} did not do anything last turn"
    elsif action == 'reinforce'
      message = '#{player_username} sent reinforcement to rebels'
    elsif action == 'recruit'
      message = '#{player_username} recruited a new spy'
    elsif action == 'mission'
      message = '#{player_username} moved his spies in the US'
    elsif action == 'attack'
      target = 
      message = "#{player_username} launch a nuclear attack on #{target}"
    end
  end 
end