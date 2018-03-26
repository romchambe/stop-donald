class GameInvitesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_invites_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(payload)
  	ActionCable.server.broadcast "game_invites_#{params[:user_id]}", {message: payload["message"], game_invite_id: payload["game_invite_id"]}
  end
end
