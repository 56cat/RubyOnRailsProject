class User::BillsController < ApplicationController

  def create
    @bill = Bill.new bill_params
    unless bill_params[:line_items_attributes].present?
      flash[:alert] = "Không có sản phẩm trong giỏ hàng"
      redirect_back(fallback_location: user_line_items_path)
      return
    end
    if @bill.save
      @message = {success: 'Đặt hàng thành công'}
    else
      @message = {errors: @bill.errors.full_messages.join('\n')}
    end

  end

  def bill_params
    params.require(:bill).permit(
      :amount,
      :payment_method,
      :user_id,
      :promotion_id,
      :total,
      :discount,
      line_items_attributes: [
        :target_type,
        :target_id,
        :price,
        :quantity,
        :discount,
        :promotion_id,
        :brand_id
      ],
      deliveries_attributes: [
        :phone,
        :note,
        :address,
        :amount,
        :brand_id,
        :user_id,
        :updated_by_id
      ]
    )
  end
end
