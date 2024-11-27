class Supplier::MessagesController < Supplier::SupplierController

  def create
    message = Message.new(message_params)
    message.user = current_user
    if message.save
      MessageJob.perform_later(message)
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :conversation_id)
  end

end
