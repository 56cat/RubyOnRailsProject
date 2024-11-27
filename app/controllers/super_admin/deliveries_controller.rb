class SuperAdmin::DeliveriesController < SuperAdmin::SuperAdminController

  before_action :find_record, only: [:show, :change_status]

  def index
    @search = Delivery.order(created_at: :desc).ransack(params[:q])
    @deliveries = @search.result.includes(:user, :bill).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'bill_code_or_user_name'
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

  def find_record
    @delivery = Delivery.find_by(id: params[:id])
    return redirect_back(fallback_location: root_path), flash[:alert] =  "Không tìm thấy đơn hàng" unless @delivery.present?
  end
end
