class Supplier::ConversationsController < Supplier::SupplierController


  def index
    @conversations = current_brand.conversations
  end

  # def create
  #   conversation = Conversation.find_or_create_by!(user_id: current_user.id, brand_id: params[:brand_id])
  #   redirect_to supplier_conversation_path(conversation)
  # rescue => e
  #   flash[:alert] = e.message
  #   redirect_back(fallback_location: root_path)
  # end

  def show
    @conversations = current_brand.conversations
    @conversation = Conversation.find_by(id: params[:id])
    return redirect_to(supplier_conversations_path, alert: 'Không tìm thấy đoạn chat') unless @conversation.present?
    return redirect_to(supplier_conversations_path, alert: 'Bạn không có quyền trong đoạn chat này') unless (current_user.user? && @conversation.user_id == current_user.id) || (current_user.supplier? && @conversation.brand_id == current_user.brand_id)
    @messages = @conversation.messages.page(params[:page]).per 10
    respond_to do |format|
      format.html
      format.js
    end
  end



end
