class Supplier::ProductsController < Supplier::SupplierController
  require 'csv'
  before_action :find_product, only: [:show]

  def index
    @search = Product.order(id: :desc).ransack(params[:q])
    @products = @search.result(distinct: true).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'name'
  end

  def search
    index
    respond_to do |format|
      format.js { render template: 'shared/index.js.erb'}
      format.html { render 'index' }
    end
  end

  def export
    products = Product.all
    respond_to do |format|
      format.csv { send_data "\uFEFF" + products.to_csv, type: :csv, filename: "products-#{Date.today}.csv" }
    end
  end

  def export_csv_queue
    params.permit!
    date = params[:date]
    csv = CsvQueue.create(file_name: "products-#{Time.now.strftime("%Y-%m-%d__%H-%M-%S")}.csv", status: 0)
    CsvQueueJob.perform_later(date, csv)
    redirect_to supplier_csv_queues_path
  end

  def show

  end

  private

  def find_product
    @product = Product.find_by(id: params[:id]) || Product.new
    return flash[:alert] = 'Không tìm thấy sản phẩm' unless @product.present?
  end

  def product_params
    params.require(:product).permit(:name, :price, :quantity, images: [])
  end

end
