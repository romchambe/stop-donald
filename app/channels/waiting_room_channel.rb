class WaitingRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "waiting_room_#{params[:waiting_room]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(payload)
  end
end
