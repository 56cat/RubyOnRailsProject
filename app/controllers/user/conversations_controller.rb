class User::ConversationsController < ApplicationController
  before_action :find_conversation, only: [:show, :get_messages]


  def index
    @conversations = current_user.conversations
  end

  def create
    conversation = Conversation.find_or_create_by!(user_id: current_user.id, brand_id: params[:brand_id])
    redirect_to user_conversation_path(conversation)
  rescue => e
    flash[:alert] = e.message
    redirect_back(fallback_location: root_path)
  end

  def show
    @conversations = current_user.conversations
    @messages = @conversation.messages.page(params[:page]).per 10
    respond_to do |format|
      format.html
      format.js
    end
  end

  def get_messages
    @messages = @conversation.messages.page(params[:page]).per 10
    respond_to do |format|
      format.js { render template: 'shared/bubble_chat.js.erb'}
    end
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
    return redirect_to(user_conversations_path, alert: 'Không tìm thấy đoạn chat') unless @conversation.present?
    return redirect_to(user_conversations_path, alert: 'Bạn không có quyền trong đoạn chat này') unless (@conversation.user.user? && @conversation.user_id == current_user.id) || (@conversation.user.supplier? && @conversation.brand_id == current_user.brand_id)
  end



end
