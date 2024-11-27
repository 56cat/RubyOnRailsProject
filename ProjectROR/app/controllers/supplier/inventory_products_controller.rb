class Supplier::InventoryProductsController < Supplier::SupplierController

  require 'csv'
  before_action :find_inventory_product, only: [:new, :edit, :update, :show]

  def index
    @search = InventoryProduct.where(brand_id: current_brand.id).order(id: :desc).ransack(params[:q])
    @inventory_products = @search.result.includes(:product).page(params[:page]).per(params[:limit] || 5)
    @search_fields = 'product_name'
    @default_query = { "brand_id_eq": current_brand.id }
  end

  def export
    products = InventoryProduct.where(brand_id: current_brand.id)
    attributes = %w{product_name sell_price quantity}
    data = GenerateCsvJob.perform_now(products, attributes)
    respond_to do |format|
      format.csv { send_data "\uFEFF" + data, charset:'utf-8',filename: "products-#{Date.today}.csv" }
    end
  end

  def download_template
    send_file(
      "#{Rails.root}/public/templates/import_inventory_product_template.csv",
      filename: "import_inventory_product_template.csv",
      type: "text/csv",
      disposition: "attachment"
    )
  end

  def import
    return unless request.post?
    if params[:commit] == 'Nhập Ngay'
      @message = ImportDataCsvService.new(params[:file], current_user, current_brand).import_inventory_products
    elsif params[:commit] == 'Xếp hàng đợi'
      dir_path = Rails.root.join("public", 'file_upload')
      Dir.mkdir(dir_path) unless File.directory?(dir_path)
      file_path = File.join(dir_path, "#{Time.now.to_i}_#{params[:file].original_filename}")
      File.open(file_path, "wb") { |f| f.write(params[:file].read.force_encoding("UTF-8")) }
      InventoryProductJob.perform_later('import_inventory_products', {file: file_path, user: current_user, brand: current_brand })
      @message = ['File của bạn đã được xếp vào hàng đợi. Hệ thống sẽ thông báo cho bạn khi hoàn thành']
    end
  end

  def new

  end

  def create
    @inventory_product = InventoryProduct.new inventory_product_params
    @inventory_product.brand_id = current_brand.id
    @inventory_product.updated_by_id = current_user.id
    @inventory_product.quantity = 0
    if @inventory_product.save
      flash[:notice] = "Thêm sản phẩm vào kho thành công"
      redirect_to edit_supplier_inventory_product_path(@inventory_product)
    else
      flash[:alert] = @inventory_product.errors.full_messages.join("\n")
      render 'new'
    end
  end

  def show
    @import_export_product_histories = @inventory_product.import_export_histories.where(brand_id: current_brand.id)
  end

  def edit

  end

  def update
    if @inventory_product.update(inventory_product_params.merge(updated_by_id: current_user.id))
      flash[:notice] = "Cập nhật kho thành công"
      redirect_to edit_supplier_inventory_product_path(@inventory_product)
    else
      flash[:alert] = @inventory_product.errors.full_messages.join("\n")
      render 'edit'
    end
  end

  private

  def find_inventory_product
    @inventory_product = InventoryProduct.find_by(id: params[:id]) || InventoryProduct.new
  end

  def inventory_product_params
    params.require(:inventory_product).permit(:product_id, :sell_price)
  end

end
