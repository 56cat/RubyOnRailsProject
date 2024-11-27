class MessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast "conversation_#{message.conversation_id}_channel",
                                 {
                                   message: message,
                                   sender: message.user.role
                                 }
  end
end
