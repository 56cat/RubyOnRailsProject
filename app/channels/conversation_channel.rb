class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "conversation_#{params[:conversation_id]}_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
