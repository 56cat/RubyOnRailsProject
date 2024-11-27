class Supplier::DeliveriesController < Supplier::SupplierController

  before_action :find_record, only: [:show, :change_status]

  def index
    @search = Delivery.where(brand_id: current_brand.id).order(created_at: :desc).ransack(params[:q])
    @deliveries = @search.result.includes(:user, :bill).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'bill_code_or_user_name'
    @default_query = { "brand_id_eq": current_brand.id }
    @filter = [
      {
        id: 'bill_payment_method_eq',
        label: 'Hình thức thanh toán',
        options: Bill.payment_methods.map{|k,v| ["#{t("bill.payment_method.#{k}")}",v]}
      },
      {
        id: 'status_eq',
        label: 'Trạng thái',
        options: Delivery.statuses.map{|k,v| ["#{t("delivery.status.#{k}")}",v]}
      }
    ]  end

  def show

  end

  def change_status
    if @delivery.update(status: params[:status], reason: params[:reason], updated_by_id: current_user.id)
      flash[:notice] = 'Change status successfully'
    else
      flash[:alert] =@delivery.errors.full_messages.join('\n')
    end
    redirect_to supplier_delivery_path(@delivery)
  end

  def find_record
    @delivery = Delivery.find_by(id: params[:id])
    return redirect_back(fallback_location: root_path), flash[:alert] =  "Không tìm thấy đơn hàng" unless @delivery.present?
  end
end
