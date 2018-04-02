class MessagesController < ApplicationController
  def read 
  	@message = Message.find(params[:message_id])
  	@message.update(read: true)
  end
end