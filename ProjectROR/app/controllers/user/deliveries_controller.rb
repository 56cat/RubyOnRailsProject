class User::DeliveriesController < ApplicationController

  before_action :find_record, only: [:show, :change_status]

  def index
    @deliveries =  Delivery.where(user_id: current_user.id)
  end

  def show
    render 'supplier/deliveries/show'
  end

  def change_status
    if @delivery.update(status: params[:status], reason: params[:reason], updated_by_id: current_user.id)
      flash[:notice] = 'Change status successfully'
    else
      flash[:alert] = @delivery.errors.full_messages.join('\n')
    end
    redirect_to user_delivery_path(@delivery)
  end

  def find_record
    @delivery = Delivery.find_by(id: params[:id])
    return redirect_back(fallback_location: root_path), flash[:alert] =  "Không tìm thấy đơn hàng" unless @delivery.present?
  end
end
