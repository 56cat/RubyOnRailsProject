class SuperAdmin::BillsController < SuperAdmin::SuperAdminController

  def index
    @search = Bill.order(created_at: :desc).ransack(params[:q])
    @bills = @search.result(district: true).page(params[:page]).per(params[:limit] || 5)
  end

  def show
    @bill = Bill.find_by(id: params[:id])
    redirect_to(super_admin_bills_path, alert: 'Không tìm thấy hóa đơn') unless @bill.present?
  end

end